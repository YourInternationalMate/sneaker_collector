class User {
  String name;  //nicht Final, soll man in den Settings ändern können
  String email;
  String password;
  String since;

  User({
    required this.name, 
    required this.email, 
    required this.password,
    required this.since});
}