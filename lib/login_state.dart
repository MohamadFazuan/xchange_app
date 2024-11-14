import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginState {
  static const String _loginStateKey = 'login_state';
  static const String _userDataKey = 'user_data';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStateKey) ?? false;
  }

  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStateKey, isLoggedIn);
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      return jsonDecode(userDataJson);
    }
    return null;
  }
}