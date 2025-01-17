import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sneaker.dart';
import '../models/user.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pages;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      items: (json['items'] as List).map((item) => fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorId;

  ApiException(this.message, {this.statusCode, this.errorId});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException() : super('No internet connection available');
}

class AuthException extends ApiException {
  AuthException() : super('Authentication failed', statusCode: 401);
}

class RateLimitException extends ApiException {
  RateLimitException() : super('Rate limit exceeded. Please try again later.', statusCode: 429);
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001/api/v1';
  static String? _accessToken;
  static String? _refreshToken;
  static DateTime? _tokenExpiry;

  // Token Getter mit automatischer Erneuerung
  static Future<String?> get token async {
    if (_accessToken != null && _tokenExpiry != null) {
      // Wenn der Token bald abläuft (weniger als 1 Minute), erneuere ihn
      if (_tokenExpiry!.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _refreshAccessToken();
      }
      return _accessToken;
    }
    
    // Versuche Token aus SharedPreferences zu laden
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    final expiryString = prefs.getString('token_expiry');
    
    if (expiryString != null) {
      _tokenExpiry = DateTime.parse(expiryString);
    }
    
    if (_accessToken != null && _tokenExpiry != null) {
      if (_tokenExpiry!.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _refreshAccessToken();
      }
      return _accessToken;
    }
    
    return null;
  }

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    try {
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      // Setze Ablaufzeit auf 14 Minuten (da Token 15 Minuten gültig ist)
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
    } catch (e) {
      throw ApiException('Failed to save tokens: $e');
    }
  }

  static Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw AuthException();
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_refreshToken'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
      } else {
        // Bei Fehler alle Token löschen
        await clearTokens();
        throw AuthException();
      }
    } catch (e) {
      await clearTokens();
      throw AuthException();
    }
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expiry');
  }

  static Future<Map<String, String>> get headers async {
      final token = await ApiService.token;
      if (token == null) throw AuthException();
      
      return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Make sure there's a space after 'Bearer'
      };
  }

  static Future<T> _handleResponse<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await request();
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 401) {
        throw AuthException();
      }

      if (response.statusCode == 429) {
        throw RateLimitException();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return parser(data);
      }

      final error = json.decode(response.body);
      print('Error response: $error');
      throw ApiException(
        error['message'] ?? error['error'] ?? 'An error occurred',
        statusCode: response.statusCode,
        errorId: error['error_id'],
      );
    } catch (e) {
      print('Exception in _handleResponse: $e');
      rethrow;
    }
  }

  // Auth Methods
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ),
      (data) {
        if (data['access_token'] != null && data['refresh_token'] != null) {
          setTokens(data['access_token'], data['refresh_token']);
        }
        return data;
      },
    );
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    return _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ),
      (data) {
        if (data['access_token'] != null && data['refresh_token'] != null) {
          setTokens(data['access_token'], data['refresh_token']);
        }
        return data;
      },
    );
  }

  static Future<void> logout() async {
    try {
      final token = await ApiService.token;
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );
      }
    } finally {
      await clearTokens();
    }
  }

  // Profile Methods
  static Future<User> getUserProfile() async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: await headers,
      ),
      (data) => User(
        name: data['user']['username'],
        email: data['user']['email'],
        password: '',
        since: data['user']['since'],
      ),
    );
  }

  static Future<User> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    final Map<String, dynamic> updateData = {};
    if (username != null) updateData['username'] = username;
    if (email != null) updateData['email'] = email;
    if (password != null) updateData['password'] = password;

    return _handleResponse(
      () async => http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: await headers,
        body: json.encode(updateData),
      ),
      (data) => User(
        name: data['user']['username'],
        email: data['user']['email'],
        password: '',
        since: data['user']['since'],
      ),
    );
  }

  // Collection Methods
  static Future<PaginatedResponse<Sneaker>> getCollection({int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/collection?page=$page'),
        headers: await headers,
      ),
      (data) {
        print('DEBUG: Raw collection response data: $data');
        final response = PaginatedResponse.fromJson(
          data,
          (json) {
            print('DEBUG: Converting JSON to Sneaker: $json');
            return Sneaker.fromJson(json);
          },
        );
        return response;
      },
    );
  }

  static Future<bool> updateCollection(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/collection'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
          'count': sneaker.count,
          'size': sneaker.size,
          'purchase_price': sneaker.purchasePrice,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromCollection(Sneaker sneaker) async {
    print('DEBUG: API Service - Removing sneaker from collection');
    print('DEBUG: API Service - Sneaker ID: ${sneaker.id}');
    print('DEBUG: API Service - Full sneaker object: ${sneaker.toString()}');

  return _handleResponse(
    () async => http.delete(
      Uri.parse('$baseUrl/collection'),
      headers: await headers,
      body: json.encode({
        'product_id': sneaker.id,
      }),
    ),
    (data) => true,
  );
}

  // Favorites Methods
  static Future<PaginatedResponse<Sneaker>> getFavorites({int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/favorites?page=$page'),
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<bool> toggleFavorite(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromFavorites(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.delete(
        Uri.parse('$baseUrl/favorites'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  // Search Methods
  static Future<PaginatedResponse<Sneaker>> searchSneakers(
    String query, {
    int page = 1,
    int limit = 20,
    String? sort,
  }) async {
    final queryParams = {
      if (query.isNotEmpty) 'query': query,
      'page': page.toString(),
      'per_page': limit.toString(),
      if (sort != null) 'sort': sort,
    };

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
    
    return _handleResponse(
      () async => http.get(
        uri,
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<Sneaker> getSneakerDetails(int productId) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await headers,
      ),
      (data) => Sneaker.fromJson(data),
    );
  }

  // E-Mail Validation
  static Future<bool> sendVerificationEmail() async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/user/send-verification'),
        headers: await headers,
      ),
      (data) => true,
    );
  }

  static Future<bool> verifyEmail(String token) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/user/verify-email'),
        headers: await headers,
        body: json.encode({
          'token': token,
        }),
      ),
      (data) => true,
    );
  }
}