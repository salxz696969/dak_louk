import 'package:dak_louk/data/repositories/base_repo.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/data/tables/tables.dart';

class OrderProductRepository extends BaseRepository<OrderProductModel> {
  @override
  String get tableName => Tables.orderProducts.tableName;

  @override
  OrderProductModel fromMap(Map<String, dynamic> map) {
    return OrderProductModel(
      id: map[Tables.orderProducts.cols.id] as int,
      orderId: map[Tables.orderProducts.cols.orderId] as int,
      productId: map[Tables.orderProducts.cols.productId] as int,
      quantity: map[Tables.orderProducts.cols.quantity] as int,
      priceSnapshot: (map[Tables.orderProducts.cols.priceSnapshot] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap(OrderProductModel model) {
    return {
      Tables.orderProducts.cols.id: model.id,
      Tables.orderProducts.cols.orderId: model.orderId,
      Tables.orderProducts.cols.productId: model.productId,
      Tables.orderProducts.cols.quantity: model.quantity,
      Tables.orderProducts.cols.priceSnapshot: model.priceSnapshot,
    };
  }
}
