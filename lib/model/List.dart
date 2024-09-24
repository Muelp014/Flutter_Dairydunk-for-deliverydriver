import 'dart:math';
import 'package:DairyDunk/model/Product.dart';
import 'package:DairyDunk/model/cartitem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class Resturant extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Product> _menu = [
    Product(
        name: "นมสดรสจืด",
        description:
            "เมจิ น้ำนมโคแท้ 100% ขนาด200ml รสชาติอร่อย เข้มข้น หอมมันและอุดมไปด้วยคุณค่าสารอาหารที่มีประโยชน์มากมายจากธรรมชาติ ",
        price: 15.00,
        imagepath: "lib/images/milk/plainmilk.png",
        catagory: ProductCatagory.Milk),
    Product(
        name: "นมสดกลิ่นเมล่อนญี่ปุ่น",
        description:
            "นมเมจิกลิ่นเมล่อนญี่ปุ่น ขนาด200ml กับรสชาติความอร่อยแบบต้นตำรับสไตล์ญี่ปุ่น หอมอร่อยชื่นใจ ได้ประโยชน์จากนมแบบเน้นๆ!",
        price: 15.00,
        imagepath: "lib/images/milk/melonmilk.png",
        catagory: ProductCatagory.Milk),
    // yogurt
    Product(
        name: "โยเกิร์ตรสพีชผสมวุ้นมะพร้าว",
        description:
            "โยเกิร์ตเมจิ รสพีชผสมวุ้นมะพร้าว หลงรักความพีชที่ละมุนเกินห้ามใจ กับโยเกิร์ตเมจิเนื้อนุ่มๆ ",
        price: 15.00,
        imagepath: "lib/images/yogurt/peachyogurt.png",
        catagory: ProductCatagory.Yogurt),
    Product(
        name: "โยเกิร์ตรสมิกซ์เบอร์รี",
        description:
            "โยเกิร์ตเมจิ รสรสมิกซ์เบอร์รี อร่อยเนื้อนุ่ม.ฟินกับผลไม้ ด้วยโยเกิร์ตเนื้อนุ่มสูตรใหม่แบบเฉพาะของเมจิ ",
        price: 15.00,
        imagepath: "lib/images/yogurt/mixedberryyogurt.png",
        catagory: ProductCatagory.Yogurt),
  ];

  // Getters
  List<Product> get menu => _menu;
  List<Cartitem> get cart => _cart;

  // User cart
  final List<Cartitem> _cart = [];

  // Add to cart
  void addToCart(Product product) {
    Cartitem? cartitem = _cart.firstWhereOrNull((item) {
      bool isSameProduct = item.product == product;
      return isSameProduct;
    });

    if (cartitem != null) {
      cartitem.quantity++;
    } else {
      _cart.add(
        Cartitem(
          product: product,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(Cartitem cartitem) {
    int cartIndex = _cart.indexOf(cartitem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

  // Get total price
  double getTotalPrice() {
    double total = 0.0;
    for (Cartitem cartitem in _cart) {
      total += cartitem.product.price * cartitem.quantity;
    }
    return total;
  }

  // Get item quantity in cart
  int getTotalItemCount() {
    int totalItemCount = 0;
    for (Cartitem cartitem in _cart) {
      totalItemCount += cartitem.quantity;
    }
    return totalItemCount;
  }

  // Clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Generate receipt
  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln();
    receipt.writeln("Here's your receipt.");
    receipt.writeln();

    // Format date
    String formatDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    receipt.writeln('Date: $formatDate');
    receipt.writeln();
    receipt.writeln("__________________");

    // Format items
    for (Cartitem cartitem in _cart) {
      receipt.writeln(
          '${cartitem.product.name} x ${cartitem.quantity} - ${_formatPrice(cartitem.product.price * cartitem.quantity)}');
    }

    // Format total price
    receipt.writeln("__________________");
    receipt.writeln();
    receipt.writeln("Total Item: ${getTotalItemCount()}");
    receipt.writeln('Total Price: ${_formatPrice(getTotalPrice())}');
    return receipt.toString();
  }

  // Format double value into money
  String _formatPrice(double price) {
    return "\฿${price.toStringAsFixed(2)}";
  }

  // Send cart data to Firestore with randomly generated paymentId
  Future<void> sendOrderToFirestore() async {
    try {
      // Generate a random 3-digit paymentId
      final int paymentId = Random().nextInt(900) +
          100; // Generates a random number between 100 and 999 inclusive

      // Get a reference to the Firestore collection
      CollectionReference orders = _firestore.collection('orders');

      // Generate a new document ID
      String orderId = orders.doc().id;

      // Prepare data to be sent
      List<Map<String, dynamic>> itemsData = _cart
          .map((cart) => {
                'productName': cart.product.name,
                'quantity': cart.quantity,
                'price per unit': cart.product.price,
              })
          .toList();

    

      double totalPrice = getTotalPrice(); // Calculate total price


      Map<String, dynamic> orderData = {
        'orderId': orderId,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentId':
            paymentId.toString(), // Convert paymentId to String for Firestore
        'items': itemsData,
        'totalPrice': totalPrice,
      };

      // Send to Firestore
      await orders.doc(orderId).set(orderData);

      // Clear the cart after successful order

    } catch (e) {
      print('Error sending order: $e');
      // Handle error appropriately
      throw e; // Optionally rethrow the error to handle it in the widget
    }
  }
}
