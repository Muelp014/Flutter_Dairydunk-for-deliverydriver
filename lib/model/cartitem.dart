import 'package:flutter/material.dart';
import 'package:DairyDunk/model/Product.dart';

class Cartitem {
  Product product;
  int quantity;

  Cartitem({
    required this.product,
    this.quantity = 1,

  });

  double get Totalprice{
    return (product.price * quantity );
  }
}