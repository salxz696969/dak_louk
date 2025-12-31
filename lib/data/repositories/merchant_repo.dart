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
      businessName: merchant[Tables.merchants.cols.businessName] as String?,
      businessDescription: merchant[Tables.merchants.cols.businessDescription] as String?,
      createdAt: DateTime.parse(merchant[Tables.merchants.cols.createdAt] as String),
      updatedAt: DateTime.parse(merchant[Tables.merchants.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(MerchantModel merchant) {
    return {
      Tables.merchants.cols.id: merchant.id,
      Tables.merchants.cols.userId: merchant.userId,
      Tables.merchants.cols.rating: merchant.rating,
      Tables.merchants.cols.businessName: merchant.businessName,
      Tables.merchants.cols.businessDescription: merchant.businessDescription,
      Tables.merchants.cols.createdAt: merchant.createdAt.toIso8601String(),
      Tables.merchants.cols.updatedAt: merchant.updatedAt.toIso8601String(),
    };
  }
}
