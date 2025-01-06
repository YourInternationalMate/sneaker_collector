import os
import logging
from datetime import datetime, timedelta, UTC
from contextlib import contextmanager
from uuid import uuid4
import redis
from logging.handlers import RotatingFileHandler
from flask import Flask, request, jsonify, g, Blueprint
from werkzeug.exceptions import HTTPException
from flask_cors import CORS
from flask_jwt_extended import (
    JWTManager, create_access_token, create_refresh_token,
    get_jwt_identity, jwt_required, get_jwt,
    verify_jwt_in_request
)
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_caching import Cache
from sqlalchemy import create_engine, Column, Integer, String, Double, ForeignKey, DateTime, Boolean, Index, event
from sqlalchemy.orm import sessionmaker, relationship, declarative_base, validates
from sqlalchemy.exc import SQLAlchemyError
from werkzeug.security import generate_password_hash, check_password_hash
from marshmallow import Schema, fields, validate, validates_schema, ValidationError
from password_validator import PasswordValidator
from dotenv import load_dotenv
from sqlalchemy import text
import secrets
from prometheus_client import Counter, Histogram
import time
from google.oauth2 import id_token
from google.auth.transport import requests

class ApiException(Exception):
    def __init__(self, message, code=400, error_id=None):
        super().__init__(message)
        self.message = message
        self.code = code
        self.error_id = error_id

class AuthException(ApiException):
    def __init__(self):
        super().__init__('Authentication failed', code=401)

class RateLimitException(ApiException):
    def __init__(self):
        super().__init__('Rate limit exceeded. Please try again later.', code=429)

class NetworkException(ApiException):
    def __init__(self):
        super().__init__('No internet connection available', code=503)

# Load environment variables
load_dotenv()

# Prometheus metrics
REQUEST_COUNT = Counter(
    'request_count', 'App Request Count',
    ['method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram(
    'request_latency_seconds', 'Request latency',
    ['method', 'endpoint']
)

# Redis setup for rate limiting and caching
redis_client = redis.from_url(os.getenv('REDIS_URL', 'redis://localhost:6379/0'))

# Create Flask app
app = Flask(__name__)

# Config classes with enhanced security settings
class Config:
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY')
    if not JWT_SECRET_KEY:
        if os.getenv('FLASK_ENV') == 'production':
            raise ValueError("JWT_SECRET_KEY must be set in production")
        JWT_SECRET_KEY = secrets.token_urlsafe(32)
    
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=15)  # Shorter lifetime for security
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    JWT_ERROR_MESSAGE_KEY = 'message'
    DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///sneaker_collector.db')
    CACHE_TYPE = "redis"
    CACHE_REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')
    CACHE_DEFAULT_TIMEOUT = 300
    LOG_DIR = "logs"
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    PERMANENT_SESSION_LIFETIME = timedelta(days=30)
    GOOGLE_CLIENT_ID = os.getenv('GOOGLE_CLIENT_ID')
    GOOGLE_CLIENT_SECRET = os.getenv('GOOGLE_CLIENT_SECRET')

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_TRACK_MODIFICATIONS = True

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    PREFERRED_URL_SCHEME = 'https'

class TestingConfig(Config):
    TESTING = True
    DATABASE_URL = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}

# Configure app
env = os.getenv('FLASK_ENV', 'default')
app.config.from_object(config[env])

# Enable CORS with stricter settings
CORS(app, resources={
    r"/api/*": {
        "origins": os.getenv('ALLOWED_ORIGINS', '*').split(','),
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["X-Request-ID"],
        "supports_credentials": True
    }
})

# Setup extensions
jwt = JWTManager(app)
cache = Cache(app)
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    storage_uri="redis://localhost:6379",
    strategy="fixed-window-elastic-expiry"
)

# Enhanced JWT callbacks
@jwt.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    jti = jwt_payload["jti"]
    token_in_redis = redis_client.get(jti)
    return token_in_redis is not None

@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    return jsonify({
        'status': 'error',
        'message': 'The token has expired',
        'error': 'token_expired'
    }), 401

@jwt.invalid_token_loader
def invalid_token_callback(error_string):
    return jsonify({
        'status': 'error',
        'message': 'Invalid token',
        'error': error_string
    }), 422

@jwt.unauthorized_loader
def unauthorized_callback(error_string):
    return jsonify({
        'status': 'error',
        'message': 'No token provided',
        'error': error_string
    }), 401

# Create API blueprint
api_v1 = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Enhanced logging setup
class RequestIdFilter(logging.Filter):
    def filter(self, record):
        record.request_id = getattr(g, 'request_id', 'no_request_id')
        record.remote_addr = request.remote_addr
        return True

def setup_logging(app):
    if not os.path.exists(Config.LOG_DIR):
        os.makedirs(Config.LOG_DIR, exist_ok=True)
    
    formatter = logging.Formatter(
        '%(asctime)s [%(levelname)s] %(remote_addr)s - %(request_id)s: %(message)s'
    )
    
    # Application log
    file_handler = RotatingFileHandler(
        f'{Config.LOG_DIR}/app.log',
        maxBytes=10240,
        backupCount=10
    )
    file_handler.setFormatter(formatter)
    
    # Error log
    error_handler = RotatingFileHandler(
        f'{Config.LOG_DIR}/error.log',
        maxBytes=10240,
        backupCount=10
    )
    error_handler.setFormatter(formatter)
    error_handler.setLevel(logging.ERROR)
    
    # Security log
    security_handler = RotatingFileHandler(
        f'{Config.LOG_DIR}/security.log',
        maxBytes=10240,
        backupCount=10
    )
    security_handler.setFormatter(formatter)
    
    # Add request ID filter
    request_id_filter = RequestIdFilter()
    file_handler.addFilter(request_id_filter)
    error_handler.addFilter(request_id_filter)
    security_handler.addFilter(request_id_filter)
    
    app.logger.addHandler(file_handler)
    app.logger.addHandler(error_handler)
    app.logger.addHandler(security_handler)
    app.logger.setLevel(logging.INFO)

# Enhanced password validation
password_schema = PasswordValidator()
password_schema\
    .min(8)\
    .max(128)\
    .has().uppercase()\
    .has().lowercase()\
    .has().digits()\
    .has().symbols()\
    .has().no().spaces()

# Enhanced request validation schemas
class LoginSchema(Schema):
    username = fields.Str(required=True)
    password = fields.Str(required=True)
    device_info = fields.Dict(required=False)

class RegisterSchema(Schema):
    username = fields.Str(
        required=True,
        validate=[
            validate.Length(min=3, max=50),
            validate.Regexp(
                '^[a-zA-Z0-9_]+$',
                error='Username can only contain letters, numbers and underscores'
            )
        ]
    )
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=lambda p: password_schema.validate(p))
    
    @validates_schema
    def validate_unique_fields(self, data, **kwargs):
        with get_db_session() as session:
            if session.query(User).filter_by(username=data['username']).first():
                raise ValidationError('Username already exists', 'username')
            if session.query(User).filter_by(email=data['email']).first():
                raise ValidationError('Email already exists', 'email')

class ProfileUpdateSchema(Schema):
    username = fields.Str(validate=[
        validate.Length(min=3, max=50),
        validate.Regexp(
            '^[a-zA-Z0-9_]+$',
            error='Username can only contain letters, numbers and underscores'
        )
    ])
    email = fields.Email()
    password = fields.Str(validate=lambda p: password_schema.validate(p))
    current_password = fields.Str(required=True)

class CollectionSchema(Schema):
    product_id = fields.Int(required=True)
    count = fields.Int(required=True, validate=validate.Range(min=1, max=100))
    size = fields.Float(required=True, validate=validate.Range(min=1, max=25))
    purchase_price = fields.Float(validate=validate.Range(min=0))

# Database setup with connection pooling and retry mechanism
def create_engine_with_retry():
    return create_engine(
        Config.DATABASE_URL,
        pool_size=5,
        max_overflow=10,
        pool_timeout=30,
        pool_recycle=1800,
        pool_pre_ping=True
    )

Base = declarative_base()
engine = create_engine_with_retry()
Session = sessionmaker(bind=engine)

# Enhanced session manager with retry mechanism
@contextmanager
def get_db_session(retry_count=3):
    session = Session()
    try:
        yield session
        session.commit()
    except SQLAlchemyError as e:
        session.rollback()
        if retry_count > 0:
            app.logger.warning(f"Database error, retrying... ({retry_count} attempts left)")
            with get_db_session(retry_count - 1) as new_session:
                yield new_session
        else:
            app.logger.error(f"Database error after all retries: {str(e)}")
            raise
    finally:
        session.close()

# Enhanced Models with validation
class User(Base):
    __tablename__ = 'users'
    __table_args__ = (
        Index('idx_user_username', 'username', unique=True),
        Index('idx_user_email', 'email', unique=True),
    )
    
    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(120), unique=True, nullable=False)
    password_hash = Column(String(256), nullable=False)
    created_at = Column(DateTime, nullable=False, default=lambda: datetime.now(UTC))
    last_login = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    failed_login_attempts = Column(Integer, default=0, nullable=False)
    
    collections = relationship('Collection', back_populates='user', cascade='all, delete-orphan')
    favorites = relationship('Favorite', back_populates='user', cascade='all, delete-orphan')

    @validates('username')
    def validate_username(self, key, username):
        if not username or len(username) < 3:
            raise ValueError('Username must be at least 3 characters long')
        if not username.isalnum():
            raise ValueError('Username must be alphanumeric')
        return username

    @validates('email')
    def validate_email(self, key, email):
        if not email or '@' not in email:
            raise ValueError('Invalid email address')
        return email

    def set_password(self, password):
        if not password_schema.validate(password):
            raise ValueError('Password does not meet security requirements')
        self.password_hash = generate_password_hash(password, method='pbkdf2:sha256:100000')

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username or '',  # Fallback zu leerem String
            'email': self.email or '',        # Fallback zu leerem String
            'since': self.created_at.strftime('%Y-%m-%d') if self.created_at else '',  # Fallback zu leerem String
            'is_active': self.is_active if self.is_active is not None else True  # Fallback zu True
        }

class Product(Base):
    __tablename__ = 'products'
    __table_args__ = (
        Index('idx_product_search', 'model', 'brand', 'name'),
    )
    
    id = Column(Integer, primary_key=True)
    model = Column(String(100), nullable=False)
    brand = Column(String(100), nullable=False)
    name = Column(String(200), nullable=False)
    price = Column(Double, nullable=False)
    image_url = Column(String(500))
    stock_x_url = Column(String(500))
    goat_url = Column(String(500))
    created_at = Column(DateTime, default=lambda: datetime.now(UTC))
    updated_at = Column(DateTime, onupdate=lambda: datetime.now(UTC))
    
    collections = relationship('Collection', back_populates='product', cascade='all, delete-orphan')
    favorites = relationship('Favorite', back_populates='product', cascade='all, delete-orphan')

    @validates('price')
    def validate_price(self, key, price):
        if price < 0:
            raise ValueError('Price cannot be negative')
        return price

    def to_dict(self, user_id=None):
        data = {
            'id': self.id,
            'model': self.model,
            'brand': self.brand,
            'name': self.name,
            'price': self.price,
            'image_url': self.image_url,
            'stock_x_url': self.stock_x_url,
            'goat_url': self.goat_url,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if user_id:
            with get_db_session() as session:
                try:
                    data['in_collection'] = session.query(Collection).filter_by(
                        user_id=user_id, 
                        product_id=self.id
                    ).first() is not None
                    
                    data['in_favorites'] = session.query(Favorite).filter_by(
                        user_id=user_id, 
                        product_id=self.id
                    ).first() is not None
                except SQLAlchemyError as e:
                    app.logger.error(f"Database error in Product.to_dict: {str(e)}")
                    data['in_collection'] = False
                    data['in_favorites'] = False
            
        return data

class Collection(Base):
    __tablename__ = 'collections'
    __table_args__ = (
        Index('idx_collection_user', 'user_id'),
        Index('idx_collection_user_product', 'user_id', 'product_id', unique=True),
    )
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    product_id = Column(Integer, ForeignKey('products.id', ondelete='CASCADE'), nullable=False)
    count = Column(Integer, nullable=False, default=1)
    size = Column(Double, nullable=False)
    purchase_price = Column(Double)
    created_at = Column(DateTime, default=lambda: datetime.now(UTC))
    updated_at = Column(DateTime, onupdate=lambda: datetime.now(UTC))
    
    user = relationship('User', back_populates='collections')
    product = relationship('Product', back_populates='collections')

    @validates('count')
    def validate_count(self, key, count):
        if count < 1:
            raise ValueError('Count must be at least 1')
        if count > 100:
            raise ValueError('Count cannot exceed 100')
        return count

    @validates('size')
    def validate_size(self, key, size):
        if size < 1 or size > 25:
            raise ValueError('Invalid shoe size')
        return size

    @validates('purchase_price')
    def validate_purchase_price(self, key, price):
        if price is not None and price < 0:
            raise ValueError('Purchase price cannot be negative')
        return price

    def to_dict(self):
        return {
            'id': self.id,
            'product_id': self.product_id,
            'model': self.product.model,
            'brand': self.product.brand,
            'name': self.product.name,
            'count': self.count,
            'size': self.size,
            'purchase_price': self.purchase_price,
            'image_url': self.product.image_url,
            'price': self.product.price,
            'stock_x_url': self.product.stock_x_url,
            'goat_url': self.product.goat_url,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Favorite(Base):
    __tablename__ = 'favorites'
    __table_args__ = (
        Index('idx_favorite_user', 'user_id'),
        Index('idx_favorite_user_product', 'user_id', 'product_id', unique=True),
    )
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    product_id = Column(Integer, ForeignKey('products.id', ondelete='CASCADE'), nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(UTC))
    
    user = relationship('User', back_populates='favorites')
    product = relationship('Product', back_populates='favorites')

    def to_dict(self):
        return {
            'id': self.id,
            'product_id': self.product_id,
            'model': self.product.model,
            'brand': self.product.brand,
            'name': self.product.name,
            'image_url': self.product.image_url,
            'price': self.product.price,
            'stock_x_url': self.product.stock_x_url,
            'goat_url': self.product.goat_url,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

# Enhanced Request tracking with metrics
@app.before_request
def before_request():
    g.request_id = request.headers.get('X-Request-ID', str(uuid4()))
    g.start_time = time.time()
    g.request_endpoint = request.endpoint

@app.after_request
def after_request(response):
    # Add security headers
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['X-Request-ID'] = g.request_id
    
    # Add metrics
    if hasattr(g, 'request_endpoint'):
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=g.request_endpoint or 'unknown',
            http_status=response.status_code
        ).inc()
        
        if hasattr(g, 'start_time'):
            REQUEST_LATENCY.labels(
                method=request.method,
                endpoint=g.request_endpoint or 'unknown'
            ).observe(time.time() - g.start_time)
    
    return response

# Basic routes with enhanced security and caching
@app.route('/')
@cache.cached(timeout=3600)
def index():
    return jsonify({
        'message': 'Welcome to Sneaker Collector API',
        'version': '2.0.0',
        'endpoints': '/api/v1',
    })

@app.route('/health')
def health_check():
    status = {
        'status': 'healthy',
        'timestamp': datetime.now(UTC).isoformat(),
        'version': '2.0.0',
        'services': {}
    }
    
    # Check database
    try:
        with get_db_session() as session:
            session.execute(text('SELECT 1'))
        status['services']['database'] = 'healthy'
    except Exception as e:
        app.logger.error(f"Database health check failed: {e}")
        status['services']['database'] = 'unhealthy'
        status['status'] = 'unhealthy'

    # Check Redis
    try:
        redis_client.ping()
        status['services']['redis'] = 'healthy'
    except Exception as e:
        app.logger.error(f"Redis health check failed: {e}")
        status['services']['redis'] = 'unhealthy'
        status['status'] = 'unhealthy'
    
    return jsonify(status), 200 if status['status'] == 'healthy' else 500

@app.route('/metrics')
def metrics():
    from prometheus_client import generate_latest
    return generate_latest()

#Login with Google
@api_v1.route('/auth/google', methods=['POST'])
@limiter.limit("5 per minute")
def google_auth():
    try:
        # Get the ID token sent by the client
        token = request.json.get('id_token')
        if not token:
            return jsonify({
                'status': 'error',
                'message': 'No token provided'
            }), 400

        # Verify the token
        idinfo = id_token.verify_oauth2_token(
            token, 
            requests.Request(), 
            GOOGLE_CLIENT_ID
        )

        # Get user info from token
        google_id = idinfo['sub']
        email = idinfo['email']
        name = idinfo.get('name', '').split()[0]  # Use first name as username
        
        with get_db_session() as session:
            # Check if user exists
            user = session.query(User).filter_by(email=email).first()
            
            if not user:
                # Create new user
                user = User(
                    username=f"{name}_{google_id[:6]}", # Create unique username
                    email=email,
                    is_active=True
                )
                user.set_password(secrets.token_urlsafe(32))  # Set random secure password
                session.add(user)
                session.flush()
            
            # Generate tokens
            access_token = create_access_token(identity=str(user.id))
            refresh_token = create_refresh_token(identity=str(user.id))
            
            # Update last login
            user.last_login = datetime.now(UTC)
            session.commit()
            
            return jsonify({
                'status': 'success',
                'message': 'Login successful',
                'access_token': access_token,
                'refresh_token': refresh_token,
                'user': user.to_dict()
            }), 200
            
    except ValueError:
        # Invalid token
        return jsonify({
            'status': 'error',
            'message': 'Invalid token'
        }), 401
    except Exception as e:
        app.logger.error(f"Google auth error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Authentication failed'
        }), 500

# Enhanced API routes with better security and error handling
@api_v1.route('/login', methods=['POST'])
@limiter.limit("5 per minute")
def login():
    try:
        schema = LoginSchema()
        data = schema.load(request.json)
    except ValidationError as err:
        return jsonify({"status": "error", "message": "Validation error", "errors": err.messages}), 400
    
    with get_db_session() as session:
        user = session.query(User).filter_by(username=data['username']).first()
        
        if user and user.check_password(data['password']):
            if not user.is_active:
                return jsonify({
                    'status': 'error',
                    'message': 'Account is deactivated'
                }), 401

            # Reset failed login attempts
            user.failed_login_attempts = 0
            user.last_login = datetime.now(UTC)
            
            # Generate tokens
            access_token = create_access_token(identity=str(user.id))
            refresh_token = create_refresh_token(identity=str(user.id))
            
            # Log successful login
            app.logger.info(f"Successful login for user: {user.username}", 
                          extra={'user_id': user.id})
            
            return jsonify({
                'status': 'success',
                'message': 'Login successful',
                'access_token': access_token,
                'refresh_token': refresh_token,
                'user': user.to_dict()
            }), 200
        
        # Handle failed login
        if user:
            user.failed_login_attempts += 1
            if user.failed_login_attempts >= 5:
                user.is_active = False
                app.logger.warning(f"Account locked due to too many failed attempts: {user.username}")
        
        app.logger.warning(f"Failed login attempt for username: {data['username']}")
        return jsonify({
            'status': 'error',
            'message': 'Invalid credentials'
        }), 401

@api_v1.route('/register', methods=['POST'])
@limiter.limit("3 per hour")
def register():
    try:
        schema = RegisterSchema()
        data = schema.load(request.json)
    except ValidationError as err:
        return jsonify({"status": "error", "message": "Validation error", "errors": err.messages}), 400
    
    with get_db_session() as session:
        try:
            new_user = User(
                username=data['username'],
                email=data['email']
            )
            new_user.set_password(data['password'])
            
            session.add(new_user)
            session.flush()  # Get the ID without committing
            
            # Generate tokens
            access_token = create_access_token(identity=str(new_user.id))
            refresh_token = create_refresh_token(identity=str(new_user.id))
            
            session.commit()
            
            # Log successful registration
            app.logger.info(f"New user registered: {new_user.username}", 
                          extra={'user_id': new_user.id})
            
            return jsonify({
                'status': 'success',
                'message': 'User registered successfully',
                'access_token': access_token,
                'refresh_token': refresh_token,
                'user': new_user.to_dict()
            }), 201
            
        except SQLAlchemyError as e:
            session.rollback()
            app.logger.error(f"Database error during registration: {str(e)}")
            return jsonify({
                'status': 'error',
                'message': 'Registration failed due to database error'
            }), 500

@api_v1.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    current_user_id = get_jwt_identity()
    new_access_token = create_access_token(identity=current_user_id)
    return jsonify({
        'access_token': new_access_token
    }), 200

@api_v1.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    jti = get_jwt()["jti"]
    redis_client.set(jti, "", ex=Config.JWT_ACCESS_TOKEN_EXPIRES)
    return jsonify({
        'status': 'success',
        'message': 'Successfully logged out'
    }), 200

@api_v1.route('/user/profile', methods=['GET'])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    app.logger.info(f"Profile request for user_id: {user_id}")
    
    with get_db_session() as session:
        user = session.get(User, user_id)
        
        if not user:
            app.logger.error(f"User not found: {user_id}")
            return jsonify({
                'status': 'error',
                'message': 'User not found'
            }), 404
            
        return jsonify({
            'status': 'success',
            'user': user.to_dict()
        }), 200

@api_v1.route('/collection', methods=['GET', 'POST', 'DELETE'])
@jwt_required()
def manage_collection():
    user_id = int(get_jwt_identity())
    
    with get_db_session() as session:
        if request.method == 'GET':
            try:
                page = request.args.get('page', 1, type=int)
                per_page = min(request.args.get('per_page', 20, type=int), 100)
                
                query = session.query(Collection).filter_by(user_id=user_id)
                total = query.count()
                collections = query.order_by(Collection.updated_at.desc())\
                                 .offset((page - 1) * per_page)\
                                 .limit(per_page)\
                                 .all()
                
                return jsonify({
                    'status': 'success',
                    'items': [item.to_dict() for item in collections],
                    'total': total,
                    'page': page,
                    'pages': (total + per_page - 1) // per_page
                }), 200
                
            except SQLAlchemyError as e:
                app.logger.error(f"Database error in collection GET: {str(e)}")
                return jsonify({
                    'status': 'error',
                    'message': 'Failed to retrieve collection'
                }), 500
            
        elif request.method == 'POST':
            try:
                schema = CollectionSchema()
                data = schema.load(request.json)
            except ValidationError as err:
                return jsonify({
                    'status': 'error',
                    'message': 'Validation error',
                    'errors': err.messages
                }), 400
            
            try:
                product = session.get(Product, data['product_id'])
                if not product:
                    return jsonify({
                        'status': 'error',
                        'message': 'Product not found'
                    }), 404
                
                collection_item = session.query(Collection).filter(
                    Collection.user_id == user_id,
                    Collection.product_id == data['product_id']
                ).first()
                
                if collection_item:
                    # Update existing item
                    collection_item.count = data['count']
                    collection_item.size = data['size']
                    collection_item.purchase_price = data.get('purchase_price')
                    collection_item.updated_at = datetime.now(UTC)
                else:
                    # Create new item
                    collection_item = Collection(
                        user_id=user_id,
                        product_id=data['product_id'],
                        count=data['count'],
                        size=data['size'],
                        purchase_price=data.get('purchase_price')
                    )
                    session.add(collection_item)
                
                session.commit()
                
                return jsonify({
                    'status': 'success',
                    'message': 'Collection updated successfully',
                    'item': collection_item.to_dict()
                }), 200
                
            except SQLAlchemyError as e:
                session.rollback()
                app.logger.error(f"Database error in collection POST: {str(e)}")
                return jsonify({
                    'status': 'error',
                    'message': 'Failed to update collection'
                }), 500
            
        elif request.method == 'DELETE':
            if not request.is_json:
                return jsonify({
                    'status': 'error',
                    'message': 'Missing JSON data'
                }), 400

            data = request.json
            if 'product_id' not in data:
                return jsonify({
                    'status': 'error',
                    'message': 'Product ID is required'
                }), 400

            try:
                product_id = int(data['product_id'])
            except (TypeError, ValueError):
                return jsonify({
                    'status': 'error',
                    'message': 'Invalid product ID format'
                }), 400

            try:
                collection_item = session.query(Collection).filter(
                    Collection.user_id == user_id,
                    Collection.product_id == product_id
                ).first()
                
                if collection_item:
                    session.delete(collection_item)
                    session.commit()
                    return jsonify({
                        'status': 'success',
                        'message': 'Item removed from collection'
                    }), 200
                
                return jsonify({
                    'status': 'error',
                    'message': 'Item not found in collection'
                }), 404
                
            except SQLAlchemyError as e:
                session.rollback()
                app.logger.error(f"Database error in collection DELETE: {str(e)}")
                return jsonify({
                    'status': 'error',
                    'message': 'Failed to remove item from collection'
                }), 500

@api_v1.route('/favorites', methods=['GET', 'POST', 'DELETE'])
@jwt_required()
def manage_favorites():
    user_id = get_jwt_identity()
    app.logger.info(f"Favorites request - Method: {request.method}, User ID: {user_id}")
    
    try:
        with get_db_session() as session:
            if request.method == 'GET':
                page = request.args.get('page', 1, type=int)
                per_page = min(request.args.get('per_page', 20, type=int), 100)
                
                query = session.query(Favorite).filter_by(user_id=user_id)
                total = query.count()
                favorites = query.order_by(Favorite.created_at.desc())\
                                .offset((page - 1) * per_page)\
                                .limit(per_page)\
                                .all()
                
                return jsonify({
                    'status': 'success',
                    'items': [item.to_dict() for item in favorites],
                    'total': total,
                    'page': page,
                    'pages': (total + per_page - 1) // per_page
                }), 200
                
            elif request.method == 'POST':
                if not request.is_json:
                    return jsonify({
                        'status': 'error',
                        'message': 'Missing JSON data'
                    }), 400

                data = request.json
                app.logger.info(f"POST request data: {data}")
                
                if 'product_id' not in data:
                    return jsonify({
                        'status': 'error',
                        'message': 'Product ID is required'
                    }), 400

                product = session.get(Product, data['product_id'])
                if not product:
                    return jsonify({
                        'status': 'error',
                        'message': 'Product not found'
                    }), 404
                    
                existing_favorite = session.query(Favorite).filter_by(
                    user_id=user_id,
                    product_id=data['product_id']
                ).first()
                
                if existing_favorite:
                    session.delete(existing_favorite)
                    session.commit()
                    return jsonify({
                        'status': 'success',
                        'message': 'Removed from favorites'
                    }), 200
                
                new_favorite = Favorite(
                    user_id=user_id,
                    product_id=data['product_id']
                )
                session.add(new_favorite)
                session.commit()
                
                return jsonify({
                    'status': 'success',
                    'message': 'Added to favorites',
                    'item': new_favorite.to_dict()
                }), 200
                
            elif request.method == 'DELETE':
                if not request.is_json:
                    return jsonify({
                        'status': 'error',
                        'message': 'Missing JSON data'
                    }), 400

                data = request.json
                app.logger.info(f"DELETE request data: {data}")
                
                if 'product_id' not in data:
                    return jsonify({
                        'status': 'error',
                        'message': 'Product ID is required'
                    }), 400

                favorite = session.query(Favorite).filter_by(
                    user_id=user_id,
                    product_id=data['product_id']
                ).first()
                
                if favorite:
                    session.delete(favorite)
                    session.commit()
                    return jsonify({
                        'status': 'success',
                        'message': 'Removed from favorites'
                    }), 200
                
                return jsonify({
                    'status': 'error',
                    'message': 'Item not found in favorites'
                }), 404

            # Default error response wenn keine der Methoden matched
            return jsonify({
                'status': 'error',
                'message': 'Method not allowed'
            }), 405
            
    except SQLAlchemyError as e:
        app.logger.error(f"Database error in favorites: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Database error occurred'
        }), 500
    except Exception as e:
        app.logger.error(f"Unexpected error in favorites: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'An unexpected error occurred'
        }), 500

@api_v1.route('/search', methods=['GET'])
@jwt_required()
# @cache.memoize(300)
def search_products():
    user_id = get_jwt_identity()
    query = request.args.get('query', '').strip()
    page = request.args.get('page', 1, type=int)
    per_page = min(request.args.get('per_page', 20, type=int), 100)
    
    app.logger.info(f"Search request - Query: '{query}', Page: {page}, Per page: {per_page}")
    
    with get_db_session() as session:
        try:
            base_query = session.query(Product)
            
            if query:
                search_terms = query.split()
                search_filters = []
                
                for term in search_terms:
                    term_filter = (
                        Product.model.ilike(f'%{term}%') |
                        Product.brand.ilike(f'%{term}%') |
                        Product.name.ilike(f'%{term}%')
                    )
                    search_filters.append(term_filter)
                
                if search_filters:
                    base_query = base_query.filter(*search_filters)
            
            total = base_query.count()
            app.logger.info(f"Found {total} matching products")
            
            products = base_query.order_by(Product.brand, Product.model).offset((page - 1) * per_page).limit(per_page).all()
            app.logger.info(f"Returning {len(products)} products")
            
            return jsonify({
                'status': 'success',
                'items': [product.to_dict(user_id) for product in products],
                'total': total,
                'page': page,
                'pages': (total + per_page - 1) // per_page
            }), 200
            
        except SQLAlchemyError as e:
            app.logger.error(f"Database error in search: {str(e)}")
            return jsonify({
                'status': 'error',
                'message': 'Failed to search products'
            }), 500

@api_v1.route('/products/<int:product_id>', methods=['GET'])
@jwt_required()
@cache.memoize(300)
def get_product(product_id):
    user_id = get_jwt_identity()
    
    with get_db_session() as session:
        try:
            product = session.get(Product, product_id)
            
            if not product:
                return jsonify({
                    'status': 'error',
                    'message': 'Product not found'
                }), 404
            
            return jsonify({
                'status': 'success',
                'product': product.to_dict(user_id)
            }), 200
            
        except SQLAlchemyError as e:
            app.logger.error(f"Database error in get_product: {str(e)}")
            return jsonify({
                'status': 'error',
                'message': 'Failed to retrieve product'
            }), 500

# Error Handlers
@app.errorhandler(Exception)
def handle_error(error):
    error_id = str(uuid4())
    
    if isinstance(error, HTTPException):
        status_code = error.code
        message = error.description
    else:
        status_code = 500
        message = 'An unexpected error occurred'
    
    # Log error with context
    app.logger.error(
        f"Error ID: {error_id}, Status: {status_code}, Message: {str(error)}",
        exc_info=True,
        extra={
            'error_id': error_id,
            'url': request.url,
            'method': request.method,
            'ip': request.remote_addr,
            'user_agent': request.user_agent.string
        }
    )
    
    if isinstance(error, ApiException):
        return jsonify({
            'status': 'error',
            'message': str(error),
            'error_id': error_id,
            'code': error.code
        }), error.code
    
    return jsonify({
        'status': 'error',
        'message': message,
        'error_id': error_id
    }), status_code

@app.errorhandler(429)
def ratelimit_handler(e):
    return jsonify({
        'status': 'error',
        'message': 'Rate limit exceeded',
        'error': str(e.description)
    }), 429

def create_app(config_name='default'):
    # Initialize the application
    setup_logging(app)
    
    # Register blueprint
    app.register_blueprint(api_v1)
    
    # Create database tables
    Base.metadata.create_all(engine)
    
    # Create Redis indices if needed
    try:
        redis_client.ping()
    except redis.ConnectionError:
        app.logger.warning("Redis connection failed. Rate limiting and caching may not work properly.")
    
    return app

if __name__ == '__main__':
    app = create_app(os.getenv('FLASK_ENV', 'development'))
    port = int(os.getenv('PORT', 5001))
    app.run(
        host='0.0.0.0',
        port=port,
        debug=app.config['DEBUG']
    )