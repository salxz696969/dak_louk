import 'package:dak_louk/data/tables/tables.dart';

class OrderProductsTable implements DbTable<OrderProductsCols> {
  const OrderProductsTable();
  @override
  String get tableName => 'order_products';
  @override
  OrderProductsCols get cols => OrderProductsCols();
}

class OrderProductsCols extends BaseCols {
  const OrderProductsCols();
  static const String orderIdCol = 'order_id';
  static const String productIdCol = 'product_id';
  static const String quantityCol = 'quantity';
  static const String priceSnapshotCol = 'price_snapshot';

  String get orderId => orderIdCol;
  String get productId => productIdCol;
  String get quantity => quantityCol;
  String get priceSnapshot => priceSnapshotCol;
}
