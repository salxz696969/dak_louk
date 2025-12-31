import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  AppSession._internal();
  static final AppSession instance = AppSession._internal();

  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';

  int? _userId;
  String? _username;

  bool get isLoggedIn => _userId != null;

  int? get userId => _userId;
  String? get username => _username;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getInt(_keyUserId);
    _username = prefs.getString(_keyUsername);
  }

  Future<void> login({required int userId, required String username}) async {
    final prefs = await SharedPreferences.getInstance();

    _userId = userId;
    _username = username;

    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = null;
    _username = null;

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
  }
}
