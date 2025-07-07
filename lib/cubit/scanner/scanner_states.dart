abstract class ScannerStates {}

class ScannerInitialState extends ScannerStates {}

class ScannerSuccessState extends ScannerStates {}

class ScannerErrorState extends ScannerStates {
  String error;
  ScannerErrorState(this.error);
}

class ScannerLoadingState extends ScannerStates {}
