import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_n_goo/cubit/scanner/scanner_states.dart';
import 'package:shop_n_goo/data/data_sources/shopping_data_source.dart';

import '../../data/data_sources/auth_local_data_source.dart';

class ScannerCubit extends Cubit<ScannerStates> {
  ScannerCubit() : super(ScannerInitialState());
  final ShoppingDataSource _shoppingDataSource = ShoppingDataSource();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  Future<Map<String, dynamic>> scanCart(String barcodeId) async {
    emit(ScannerLoadingState());
    try {
      // Get user token
      String token = await _authLocalDataSource.getToken();
      
      // Start ESP32 session with user authentication
      final response = await _shoppingDataSource.scanCart(barcodeId, token);
      emit(ScannerSuccessState());
      return response;
    } catch (exception) {
      emit(ScannerErrorState(exception.toString()));
      throw exception;
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      String token = await _authLocalDataSource.getToken();
      return await _shoppingDataSource.getCart(token);
    } catch (exception) {
      throw exception;
    }
  }

  // ESP32 Session Methods
  Future<Map<String, dynamic>> startEsp32Session(String cartBarcode) async {
    emit(ScannerLoadingState());
    try {
      final response = await _shoppingDataSource.startEsp32Session(cartBarcode);
      emit(ScannerSuccessState());
      return response;
    } catch (exception) {
      emit(ScannerErrorState(exception.toString()));
      throw exception;
    }
  }

  // Check if user has an active session (either regular or ESP32)
  Future<bool> hasActiveSession() async {
    try {
      String token = await _authLocalDataSource.getToken();
      return await _shoppingDataSource.hasActiveSession(token);
    } catch (exception) {
      print("Error checking active session: $exception");
      return false;
    }
  }
}
