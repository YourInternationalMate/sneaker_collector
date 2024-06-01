class User {
  String name;  //nicht Final, soll man in den Settings ändern können
  String email;
  String password;

  User({
    required this.name, 
    required this.email, 
    required this.password});
}