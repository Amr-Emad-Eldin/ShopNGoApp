import 'package:dio/dio.dart';
import 'package:shop_n_goo/api_constants.dart';

class ShoppingDataSource {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<Map<String, dynamic>> scanCart(String barcodeId, String token) async {
    try {
      // Start ESP32 session with user authentication
      final Response response = await _dio.post("cart/start_session_esp32",
          data: {"cart_barcode": barcodeId},
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<Map<String, dynamic>> getCart(String token) async {
    try {
      final Response response = await _dio.get("cart/get",
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final Response response = await _dio.get("auth/me",
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<void> updateFirstName(String firstName, String oldPassword, String token) async {
    try {
      final Response response = await _dio.put("auth/update-first-name",
          data: {
            "firstName": firstName,
            "oldPassword": oldPassword,
          },
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<void> updateLastName(String lastName, String oldPassword, String token) async {
    try {
      final Response response = await _dio.put("auth/update-last-name",
          data: {
            "lastName": lastName,
            "oldPassword": oldPassword,
          },
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword, String token) async {
    try {
      final Response response = await _dio.put("auth/update-password",
          data: {
            "oldPassword": oldPassword,
            "newPassword": newPassword,
          },
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  // ESP32 Session Methods
  Future<Map<String, dynamic>> startEsp32Session(String cartBarcode) async {
    try {
      final Response response = await _dio.post("cart/start_session_esp32",
          data: {"cart_barcode": cartBarcode});
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<Map<String, dynamic>> checkEsp32Session(String cartBarcode) async {
    try {
      final Response response = await _dio.post("cart/check_esp32_session",
          data: {"cart_barcode": cartBarcode});
      return response.data;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  // Check if user has an active session
  Future<bool> hasActiveSession(String token) async {
    try {
      final Response response = await _dio.get("cart/get",
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ));
      
      final data = response.data;
      return data['session'] != null && data['session']['is_active'] == true;
    } catch (exception) {
      return false;
    }
  }
}
