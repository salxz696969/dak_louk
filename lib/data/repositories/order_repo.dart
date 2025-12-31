import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/data/tables/tables.dart';

class OrderRepository extends BaseRepository<OrderModel> {
  @override
  String get tableName => Tables.orders.tableName;

  @override
  OrderModel fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map[Tables.orders.cols.id] as int,
      userId: map[Tables.orders.cols.userId] as int,
      merchantId: map[Tables.orders.cols.merchantId] as int,
      status: map[Tables.orders.cols.status] as String,
      createdAt: DateTime.parse(map[Tables.orders.cols.createdAt] as String),
      updatedAt: DateTime.parse(map[Tables.orders.cols.updatedAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(OrderModel model) {
    return {
      Tables.orders.cols.id: model.id,
      Tables.orders.cols.userId: model.userId,
      Tables.orders.cols.merchantId: model.merchantId,
      Tables.orders.cols.status: model.status,
      Tables.orders.cols.createdAt: model.createdAt.toIso8601String(),
      Tables.orders.cols.updatedAt: model.updatedAt.toIso8601String(),
    };
  }
}
