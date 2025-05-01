import 'package:asistencias_egc/models/login/LoginResponse.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier {
  LoginResponse? _user;

  LoginResponse? get user => _user;

  void setUser(LoginResponse userData) {
    _user = userData;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}