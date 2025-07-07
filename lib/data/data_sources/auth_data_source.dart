import 'package:dio/dio.dart';
import 'package:shop_n_goo/api_constants.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/data/models/auth/request/login_request.dart';
import 'package:shop_n_goo/data/models/auth/request/register_request.dart';
import 'package:shop_n_goo/data/models/auth/response/login_response.dart';
import 'package:shop_n_goo/data/models/auth/response/register_response.dart';

class AuthDataSource {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final response =
          await _dio.post("auth/login", data: loginRequest.toJson());
      final AuthLocalDataSource authLocalDataSource = AuthLocalDataSource();
      final LoginResponse loginResponse = LoginResponse.fromJson(response.data);
      await authLocalDataSource.saveToken(loginResponse.user!.token);
      
      // Fetch complete user profile from auth/me endpoint
      try {
        final userProfileResponse = await _dio.get("auth/me",
            options: Options(
              headers: {"Authorization": "Bearer ${loginResponse.user!.token}"},
            ));
        final response = userProfileResponse.data;
        
        // Handle nested user object structure
        final userData = response['user'] ?? response;
        
        // Save complete user data
        await authLocalDataSource.saveUserData(
          userData['firstName'] ?? loginResponse.user!.firstName ?? '',
          userData['lastName'] ?? '',
        );
      } catch (e) {
        print('Failed to fetch complete user profile: $e');
        // Fallback to basic user data
        if (loginResponse.user?.firstName != null) {
          await authLocalDataSource.saveUserData(
            loginResponse.user!.firstName!,
            '', // lastName is not available in the User model
          );
        }
      }
      
      return loginResponse;
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }

  Future<RegisterResponse> register(RegisterRequest registerRequest) async {
    try {
      final response =
          await _dio.post("auth/register", data: registerRequest.toJson());
      return RegisterResponse.fromJson(response.data);
    } catch (exception) {
      String error = "Something went wrong";
      if (exception is DioException) {
        error = exception.response?.data['error'] ?? error;
      }
      throw (error);
    }
  }
}
