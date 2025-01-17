class User {
  String name;
  String email;
  String password;
  String since;
  bool isEmailVerified;

  User({
    required this.name, 
    required this.email, 
    required this.password,
    required this.since,
    this.isEmailVerified = false,
  });
}