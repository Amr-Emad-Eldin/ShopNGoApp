import 'package:shop_n_goo/data/models/auth/response/user.dart';

class LoginResponse {
  LoginResponse(
      this.message,
      this.user,);

  LoginResponse.fromJson(dynamic json) {
    message = json['message'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? message;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (user != null) {
      map['user'] = user!.toJson();
    }
    return map;
  }

}

