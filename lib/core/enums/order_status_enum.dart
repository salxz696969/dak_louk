import 'package:flutter/material.dart';

enum OrderStatusEnum {
  waiting('waiting', Colors.orange),
  accepted('accepted', Colors.blue),
  delivering('delivering', Colors.purple),
  completed('completed', Colors.green),
  cancelled('cancelled', Colors.red);

  final String name;
  final Color color;
  const OrderStatusEnum(this.name, this.color);
}
