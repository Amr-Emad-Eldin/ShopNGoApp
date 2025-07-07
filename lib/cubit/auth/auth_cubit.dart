import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_n_goo/cubit/auth/auth_states.dart';
import 'package:shop_n_goo/data/data_sources/auth_data_source.dart';
import 'package:shop_n_goo/data/models/auth/request/login_request.dart';
import 'package:shop_n_goo/data/models/auth/request/register_request.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());
  final AuthDataSource _authDataSource = AuthDataSource();

  Future<void> login(LoginRequest loginRequest) async {
    emit(AuthLoadingState());
    try {
      await _authDataSource.login(loginRequest);
      emit(AuthSuccessState());
    } catch (exception) {
      emit(AuthErrorState(exception.toString()));
    }
  }

  Future<void> register(RegisterRequest registerRequest) async {
    emit(AuthLoadingState());
    try {
      await _authDataSource.register(registerRequest);
      emit(AuthSuccessState());
    } catch (exception) {
      emit(AuthErrorState(exception.toString()));
    }
  }
}
