import 'package:dak_louk/models/product_model.dart';
import 'package:dak_louk/models/user_model.dart';
import 'package:flutter/material.dart';

class CartModel {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final String updatedAt;
  final String createdAt;

  final UserModel? user;
  final ProductModel? product;
  final UserModel? seller;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.seller,
    this.product,
  });

  factory CartModel.fromMap(
    Map<String, dynamic> cart,
    UserModel? user,
    ProductModel? product,
    UserModel? seller,
  ) {
    return CartModel(
      id: cart['id'],
      userId: cart['user_id'],
      productId: cart['product_id'],
      quantity: cart['quantity'],
      createdAt: cart['created_at'],
      updatedAt: cart['updated_at'],
      seller: seller,
      user: user,
      product: product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  CartUI ui() {
    return CartUI(
      title: product?.title ?? 'Unknown',
      price: product != null ? '\$${product!.price.toStringAsFixed(2)}' : 'N/A',
      quantity: quantity,
      image: [AssetImage(product?.image ?? 'assets/images/coffee1.png')],
      sellerName: seller?.username ?? 'Unknown',
      sellerRating: double.parse((seller?.rating ?? 0.0).toStringAsFixed(2)),
    );
  }
}

class CartUI {
  final String title;
  final String price;
  final int quantity;
  final List<AssetImage> image;
  final String sellerName;
  final double sellerRating;

  CartUI({
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
    required this.sellerName,
    required this.sellerRating,
  });
}
