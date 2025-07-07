class RegisterRequest {
  RegisterRequest(
      this.firstName,
      this.lastName, 
      this.email, 
      this.phoneNo,
      this.password, 
      this.gender,);

  String firstName;
  String lastName;
  String email;
  String? phoneNo; // Optional phone number
  String password;
  String gender;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['email'] = email;
    if (phoneNo != null && phoneNo!.isNotEmpty) {
      map['phoneNo'] = phoneNo;
    }
    map['password'] = password;
    map['gender'] = gender;
    return map;
  }

}