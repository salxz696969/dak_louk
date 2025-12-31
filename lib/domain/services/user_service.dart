import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class UserService {
  late final currentUserId;
  final UserRepository _userRepository = UserRepository();
  UserService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }

  // Business logic methods migrated from UserRepository
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final statement = Clauses.where.eq(Tables.users.cols.username, username);
      final result = await _userRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'User not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to get user by username',
      );
    }
  }

  Future<UserVM?> createUser(CreateUserDTO dto) async {
    try {
      final isAvailable = await getUserByUsername(dto.username);
      if (isAvailable != null) {
        throw AppError(
          type: ErrorType.ALREADY_EXISTS,
          message: 'Username already exists',
        );
      }
      final userModel = UserModel(
        id: 0,
        username: dto.username,
        passwordHash: dto.passwordHash,
        profileImageUrl: dto.profileImageUrl,
        bio: dto.bio,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await _userRepository.insert(userModel);
      if (id > 0) {
        final newUser = await _userRepository.getById(id);
        if (newUser != null) {
          return UserVM.fromRaw(newUser);
        }
      }
      throw AppError(type: ErrorType.NOT_FOUND, message: 'User not found');
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message: 'Failed to create user',
      );
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _userRepository.delete(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserById(int id) async {
    try {
      final newUser = await _userRepository.getById(id);
      if (newUser != null) {
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      return await _userRepository.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
