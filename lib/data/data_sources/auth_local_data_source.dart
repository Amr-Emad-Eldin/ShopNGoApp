import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_n_goo/api_constants.dart';

class AuthLocalDataSource {
  Future<String> getToken() async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();

      final String token = sharedPref.getString(CacheConstants.token)!;
      return token;
    } catch (exception) {
      throw ("Failed to get token");
    }
  }

  Future<void> removeToken() async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      sharedPref.remove(CacheConstants.token);
    } catch (exception) {
      throw ("Failed to remove token");
    }
  }

  Future<void> saveToken(String token) async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      sharedPref.setString(CacheConstants.token, token);
    } catch (exception) {
      throw ("Failed to save token");
    }
  }

  Future<void> saveUserData(String firstName, String lastName) async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      sharedPref.setString('user_first_name', firstName);
      sharedPref.setString('user_last_name', lastName);
    } catch (exception) {
      throw ("Failed to save user data");
    }
  }

  Future<String?> getFirstName() async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      return sharedPref.getString('user_first_name');
    } catch (exception) {
      throw ("Failed to get first name");
    }
  }

  Future<String?> getLastName() async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      return sharedPref.getString('user_last_name');
    } catch (exception) {
      throw ("Failed to get last name");
    }
  }

  Future<String?> getUserName() async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      return sharedPref.getString('user_first_name');
    } catch (exception) {
      throw ("Failed to get user name");
    }
  }

  Future<void> logout() async {
    try {
      final SharedPreferences sharedPref =
          await SharedPreferences.getInstance();
      // Clear all stored data
      await sharedPref.clear();
    } catch (exception) {
      throw ("Failed to logout");
    }
  }
}
