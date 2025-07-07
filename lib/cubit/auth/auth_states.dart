abstract class AuthStates{}

class AuthInitialState extends AuthStates{
}

class AuthErrorState extends AuthStates{

  String message;
  AuthErrorState(this.message);
}

class AuthSuccessState extends AuthStates{}

class AuthLoadingState extends AuthStates{}