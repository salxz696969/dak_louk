import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/core/utils/hash.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dak_louk/core/enums/role_enum.dart';

class AppSession {
  AppSession._internal();
  static final AppSession instance = AppSession._internal();

  final UserRepository _userRepository = UserRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();

  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyRole = 'role';

  int? _userId;
  String? _username;
  Role? _role;

  bool get isLoggedIn => _userId != null;

  int? get userId => _userId;
  String? get username => _username;
  Role? get role => _role;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getInt(_keyUserId);
    _username = prefs.getString(_keyUsername);
    final checkRole = prefs.getString(_keyRole);
    _role = checkRole != null ? Role.values.byName(checkRole) : null;
  }

  Future<void> login({required String email, required String password}) async {
    final passwordHash = Hasher.sha256Hash(password);
    final user = await _userRepository.getUserByEmailAndPassword(
      email,
      passwordHash,
    );
    final merchant = await _merchantRepository.getMerchantByEmailAndPassword(
      email,
      passwordHash,
    );
    if (user == null && merchant == null) {
      throw AppError(type: ErrorType.NOT_FOUND, message: 'User not found');
    }
    // either the user is null or the merchant is null never both
    if (user != null) {
      _userId = user.id;
      _username = user.username;
      _role = Role.user;
    }
    if (merchant != null) {
      _userId = merchant.id;
      _username = merchant.username;
      _role = Role.merchant;
    }
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyUserId, _userId!);
    await prefs.setString(_keyUsername, _username!);
    await prefs.setString(_keyRole, _role!.name);
  }

  Future<void> signUpUser({
    required String email,
    required String username,
    required String profileImageUrl,
    required String bio,
    required String password,
  }) async {
    final passwordHash = Hasher.sha256Hash(password);
    final user = await _userRepository.getUserByEmailAndPassword(
      email,
      passwordHash,
    );
    if (user != null) {
      throw AppError(
        type: ErrorType.ALREADY_EXISTS,
        message: 'User already exists',
      );
    }
    final userModel = UserModel(
      id: 0,
      username: username,
      passwordHash: passwordHash,
      profileImageUrl: profileImageUrl,
      bio: bio,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final id = await _userRepository.insert(userModel);
    if (id > 0) {
      _userId = id;
      _username = username;
      _role = Role.user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserId, _userId!);
      await prefs.setString(_keyUsername, _username!);
      await prefs.setString(_keyRole, _role!.name);
    } else {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to sign up user',
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = null;
    _username = null;
    _role = null;

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
  }
}
