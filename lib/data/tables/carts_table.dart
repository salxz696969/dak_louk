import 'package:dak_louk/data/tables/tables.dart';

class CartsTable implements DbTable<CartsCols> {
  const CartsTable();
  @override
  String get tableName => 'carts';
  @override
  CartsCols get cols => CartsCols();
}

class CartsCols extends BaseCols {
  const CartsCols();
  static const String userIdCol = 'user_id';
  static const String productIdCol = 'product_id';
  static const String quantityCol = 'quantity';

  String get userId => userIdCol;
  String get productId => productIdCol;
  String get quantity => quantityCol;
}
