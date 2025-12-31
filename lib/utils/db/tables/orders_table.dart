import 'package:dak_louk/utils/db/tables/tables.dart';

class OrdersTable implements DbTable<OrdersCols> {
  const OrdersTable();
  @override
  String get tableName => 'orders';
  @override
  OrdersCols get cols => OrdersCols();
}

class OrdersCols extends BaseCols {
  const OrdersCols();
  static const String userIdCol = 'user_id';
  static const String merchantIdCol = 'merchant_id';
  static const String statusCol = 'status';

  String get userId => userIdCol;
  String get merchantId => merchantIdCol;
  String get status => statusCol;
}
