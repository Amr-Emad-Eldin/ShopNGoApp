class RegisterResponse {
  RegisterResponse(
      this.message,);

  RegisterResponse.fromJson(dynamic json) {
    message = json['message'];
  }
 late String message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    return map;
  }

}