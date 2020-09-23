import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travego/screens/auth.dart';

class Auth with ChangeNotifier {
  String _token;
  String _fullName;
  int _userId;
  bool isAuthenticated = false;

  int get userId {
    return _userId;
  }

  String get fullName {
    return _fullName;
  }

  bool get isAuth {
    return _token != null;
  }

  Future<void> authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.get('token');
    if (_token == null) return false;
    notifyListeners();
    return true;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }
    _token = prefs.getString('token');
    _userId = prefs.getInt('userId');
    _fullName = prefs.getString('fullName');
    notifyListeners();
    return true;
  }

  Future<void> logout(BuildContext context) async {
    _token = null;
    _userId = null;
    _fullName = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  }
}
