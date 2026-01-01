import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';

class MerchantRepository extends BaseRepository<MerchantModel> {
  @override
  String get tableName => Tables.merchants.tableName;

  @override
  MerchantModel fromMap(Map<String, dynamic> merchant) {
    return MerchantModel(
      id: merchant[Tables.merchants.cols.id] as int,
      userId: merchant[Tables.merchants.cols.userId] as int,
      rating: merchant[Tables.merchants.cols.rating] as double,
      username: merchant[Tables.merchants.cols.username] as String,
      bio: merchant[Tables.merchants.cols.bio] as String,
      email: merchant[Tables.merchants.cols.email] as String,
      profileImage: merchant[Tables.merchants.cols.profileImage] as String,
      createdAt: DateTime.parse(
        merchant[Tables.merchants.cols.createdAt] as String,
      ),
      updatedAt: DateTime.parse(
        merchant[Tables.merchants.cols.updatedAt] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(MerchantModel merchant) {
    return {
      Tables.merchants.cols.id: merchant.id,
      Tables.merchants.cols.userId: merchant.userId,
      Tables.merchants.cols.rating: merchant.rating,
      Tables.merchants.cols.username: merchant.username,
      Tables.merchants.cols.bio: merchant.bio,
      Tables.merchants.cols.email: merchant.email,
      Tables.merchants.cols.createdAt: merchant.createdAt.toIso8601String(),
      Tables.merchants.cols.updatedAt: merchant.updatedAt.toIso8601String(),
    };
  }

  // aditional methods for auth
  Future<MerchantModel?> getMerchantByEmailAndPassword(
    String email,
    String passwordHash,
  ) async {
    final statement = Clauses.where.eq(Tables.merchants.cols.email, email);

    final statement2 = Clauses.where.eq(
      Tables.merchants.cols.passwordHash,
      passwordHash,
    );
    final result = await queryThisTable(
      where: statement.clause + ' AND ' + statement2.clause,
      args: statement.args + statement2.args,
    );
    return result.firstOrNull;
  }
}
