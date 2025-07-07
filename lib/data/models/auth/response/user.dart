class User {
  User(
     this.token,
     this.email,
     this.firstName,);

  User.fromJson(dynamic json) {
    token = json['token'];
    email = json['email'];
    firstName = json['firstName'];
  }
  late  String token;
  late String email;
  late String firstName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['email'] = email;
    map['firstName'] = firstName;
    return map;
  }

}