import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/enums/role_enum.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/core/utils/hash.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/data/repositories/merchant_repo.dart';
import 'package:dak_louk/domain/models/models.dart';

class AuthService {
  final UserRepository _userRepository = UserRepository();
  final MerchantRepository _merchantRepository = MerchantRepository();

  Future<Role?> login(LogInDTO dto) async {
    final passwordHash = Hasher.sha256Hash(dto.password);
    final user = await _userRepository.getUserByEmailAndPassword(
      dto.email,
      passwordHash,
    );
    final merchant = await _merchantRepository.getMerchantByEmailAndPassword(
      dto.email,
      passwordHash,
    );
    // either the user is null or the merchant is null never both and both null on incorrect
    if (user == null && merchant == null) {
      return null;
    }

    if (user != null) {
      // Standard user login
      await AppSession.instance.setUserSession(
        userId: user.id,
        username: user.username,
        role: Role.user,
        phone: user.phone,
        address: user.address,
      );
      return Role.user;
    }
    if (merchant != null) {
      // Merchant login, fill both sections
      await AppSession.instance.setMerchantSession(
        userId: merchant.id,
        username: merchant.username,
        role: Role.merchant,
        merchantId: merchant.id,
        merchantUsername: merchant.username,
        merchantProfileImageUrl: merchant.profileImage,
      );
      return Role.merchant;
    }
    // fallback (should never reach)
    return null;
  }

  Future<void> signUpUser(SignUpDTO dto) async {
    final passwordHash = Hasher.sha256Hash(dto.password);
    final user = await _userRepository.getUserByEmailAndPassword(
      dto.email,
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
      username: dto.username,
      passwordHash: passwordHash,
      profileImageUrl: dto.profileImageUrl,
      bio: dto.bio,
      phone: dto.phone,
      address: dto.address,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final id = await _userRepository.insert(userModel);
    if (id > 0) {
      await AppSession.instance.setUserSession(
        userId: id,
        username: dto.username,
        role: Role.user,
        phone: dto.phone,
        address: dto.address,
      );
    } else {
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to sign up user',
      );
    }
  }

  Future<void> logout() async {
    await AppSession.instance.logout();
  }
}
