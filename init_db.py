from app import create_app, Base, engine

def init_database():
    app = create_app()
    with app.app_context():
        Base.metadata.drop_all(engine)
        Base.metadata.create_all(engine)
        print("Datenbank wurde erfolgreich neu initialisiert!")

if __name__ == "__main__":
    init_database()