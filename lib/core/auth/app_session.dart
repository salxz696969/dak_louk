import 'package:dak_louk/core/enums/role_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  AppSession._internal();
  static final AppSession instance = AppSession._internal();

  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyRole = 'role';
  static const _keyPhone = 'phone';
  static const _keyAddress = 'address';

  static const _keyMerchantId = 'merchant_id';
  static const _keyMerchantUsername = 'merchant_username';
  static const _keyMerchantProfileImageUrl = 'merchant_profile_image_url';

  int? _userId;
  String? _username;
  String? _phone;
  String? _address;

  int? _merchantId;
  String? _merchantUsername;
  String? _merchantProfileImageUrl;

  Role? _role;

  bool get isLoggedIn => _userId != null;

  int? get userId => _userId;
  String? get username => _username;
  String? get phone => _phone;
  String? get address => _address;
  Role? get role => _role;

  int? get merchantId => _merchantId;
  String? get merchantUsername => _merchantUsername;
  String? get merchantProfileImageUrl => _merchantProfileImageUrl;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getInt(_keyUserId);
    _username = prefs.getString(_keyUsername);
    _merchantId = prefs.getInt(_keyMerchantId);
    _merchantUsername = prefs.getString(_keyMerchantUsername);
    _merchantProfileImageUrl = prefs.getString(_keyMerchantProfileImageUrl);
    final checkRole = prefs.getString(_keyRole);
    _role = checkRole != null ? Role.values.byName(checkRole) : null;
    _phone = prefs.getString(_keyPhone);
    _address = prefs.getString(_keyAddress);
  }

  Future<void> setUserSession({
    required int userId,
    required String username,
    required Role role,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _userId = userId;
    _username = username;
    _role = role;
    _phone = phone;
    _address = address;

    _merchantId = null;
    _merchantUsername = null;
    _merchantProfileImageUrl = null;

    await prefs.setInt(_keyUserId, _userId!);
    await prefs.setString(_keyUsername, _username!);
    await prefs.setString(_keyRole, _role!.name);
    if (_phone != null) {
      await prefs.setString(_keyPhone, _phone!);
    } else {
      await prefs.remove(_keyPhone);
    }
    if (_address != null) {
      await prefs.setString(_keyAddress, _address!);
    } else {
      await prefs.remove(_keyAddress);
    }

    await prefs.remove(_keyMerchantId);
    await prefs.remove(_keyMerchantUsername);
    await prefs.remove(_keyMerchantProfileImageUrl);
  }

  Future<void> setMerchantSession({
    required int userId,
    required String username,
    required Role role,
    required int merchantId,
    required String merchantUsername,
    String? merchantProfileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _userId = userId;
    _username = username;
    _role = role;
    _merchantId = merchantId;
    _merchantUsername = merchantUsername;
    _merchantProfileImageUrl = merchantProfileImageUrl;

    _phone = null;
    _address = null;

    await prefs.setInt(_keyUserId, _userId!);
    await prefs.setString(_keyUsername, _username!);
    await prefs.setString(_keyRole, _role!.name);

    await prefs.setInt(_keyMerchantId, _merchantId!);
    await prefs.setString(_keyMerchantUsername, _merchantUsername!);

    if (_merchantProfileImageUrl != null) {
      await prefs.setString(
        _keyMerchantProfileImageUrl,
        _merchantProfileImageUrl!,
      );
    } else {
      await prefs.remove(_keyMerchantProfileImageUrl);
    }

    await prefs.remove(_keyPhone);
    await prefs.remove(_keyAddress);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = null;
    _username = null;
    _role = null;
    _phone = null;
    _address = null;

    _merchantId = null;
    _merchantUsername = null;
    _merchantProfileImageUrl = null;

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyAddress);

    await prefs.remove(_keyMerchantId);
    await prefs.remove(_keyMerchantUsername);
    await prefs.remove(_keyMerchantProfileImageUrl);
  }
}
