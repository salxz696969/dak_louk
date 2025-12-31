import 'package:dak_louk/data/repositories/user_repo.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/tables/tables.dart';

class UserService {
  final UserRepository _userRepository = UserRepository();

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
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final statement = Clauses.where.eq(Tables.users.cols.role, role);
      final orderByStmt = Clauses.orderBy.desc(Tables.users.cols.createdAt);
      final result = await _userRepository.queryThisTable(
        where: statement.clause,
        args: statement.args,
        orderBy: orderByStmt.clause,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getTopRatedUsers({int limit = 10}) async {
    try {
      final orderByStmt = Clauses.orderBy.desc(Tables.users.cols.rating);
      final result = await _userRepository.queryThisTable(
        orderBy: orderByStmt.clause,
        limit: limit,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Authentication related business logic
  Future<UserModel?> authenticateUser(
    String username,
    String passwordHash,
  ) async {
    try {
      final user = await getUserByUsername(username);
      if (user != null && user.passwordHash == passwordHash) {
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // User management business logic
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final user = await getUserByUsername(username);
      return user == null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> createUser(UserModel user) async {
    try {
      final isAvailable = await isUsernameAvailable(user.username);
      if (!isAvailable) {
        throw Exception('Username already exists');
      }

      final id = await _userRepository.insert(user);
      final newUser = await _userRepository.getById(id);
      if (newUser != null) {
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> updateUserProfile(UserModel user) async {
    try {
      await _userRepository.update(user);
      final newUser = await _userRepository.getById(user.id);
      if (newUser != null) {
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
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
