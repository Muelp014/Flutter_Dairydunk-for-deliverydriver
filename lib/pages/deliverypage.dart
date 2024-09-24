import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DairyDunk/model/fetchdata.dart';

class DeliveryPage extends StatelessWidget {
  final String orderId;

  DeliveryPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการคำสั่งจัดส่ง'),
      ),
      body: OrderList(orderId: orderId),
    );
  }
}

class OrderList extends StatefulWidget {
  final String orderId;

  OrderList({required this.orderId});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late Future<List<FetchDataOrder>> _Orders_list;
  Color sendAcceptedByButtonColor = Colors.grey;
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? '';
  String? deliveryStatus;

  @override
  void initState() {
    super.initState();
    _Orders_list = fetchOrders_list(widget.orderId);
    fetchDeliveryStatus();
  }

  Future<void> fetchDeliveryStatus() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Orders_list')
          .doc(widget.orderId)
          .get();
      setState(() {
        deliveryStatus = snapshot.data()?['deliveryStatus'];
      });
    } catch (e) {
      print('Error fetching delivery status: $e');
    }
  }

  Future<List<FetchDataOrder>> fetchOrders_list(String orderId) async {
    List<FetchDataOrder> Orders_list = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Orders_list')
          .where('orderId', isEqualTo: orderId)
          .get();
      snapshot.docs.forEach((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          FetchDataOrder order = FetchDataOrder.fromMap(data);
          Orders_list.add(order);
        }
      });
    } catch (e) {
      print('Error fetching Orders_list: $e');
    }
    return Orders_list;
  }

  void launchGoogleMaps(String location) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'ไม่สามารถเปิด Google Maps ได้ $googleMapsUrl';
    }
  }

  Future<bool> checkEmployeeInventory(
      String employeeEmail, List<dynamic> orderItems) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('employeeInventory')
          .doc(employeeEmail)
          .get();

      if (snapshot.exists) {
        List<dynamic>? inventoryData = snapshot.data()?['inventory'];

        if (inventoryData != null) {
          for (var item in orderItems) {
            String productName = item['productName'];
            int requiredQuantity = item['quantity'];

            var product = inventoryData.firstWhere(
              (inventoryItem) => inventoryItem['productId'] == productName,
              orElse: () => null,
            );

            if (product == null || product['quantity'] < requiredQuantity) {
              return false; // Not enough inventory for this product
            }
          }
          return true; // All items are available in sufficient quantity
        }
      }
    } catch (e) {
      print('Error checking employee inventory: $e');
    }
    return false;
  }

  Future<void> updateDeliveryStatusAndRecordSale(
      String orderId, BuildContext context, List<dynamic> orderItems) async {
    try {
      // Update delivery status
      await FirebaseFirestore.instance
          .collection('Orders_list')
          .doc(orderId)
          .update({'deliveryStatus': 'Paid'});
      print('อัพเดทสถานะการจัดส่งเป็น "Paid" เรียบร้อยแล้ว');

      // Update employee inventory
      bool hasEnoughInventory = await checkEmployeeInventory(
          FirebaseAuth.instance.currentUser!.email!, orderItems);

      if (hasEnoughInventory) {
        await updateEmployeeInventory(
            FirebaseAuth.instance.currentUser!.email!, orderItems);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('สินค้าที่มีไม่เพียงพอในการจัดส่ง')),
        );
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัพเดทสถานะการจัดส่ง: $e');
    }
  }

  Future<void> updateEmployeeInventory(
      String employeeEmail, List<dynamic> orderItems) async {
    try {
      DocumentReference<Map<String, dynamic>> inventoryRef = FirebaseFirestore
          .instance
          .collection('employeeInventory')
          .doc(employeeEmail);

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await inventoryRef.get();
      List<dynamic> inventoryData = snapshot.exists && snapshot.data() != null
          ? snapshot.data()!['inventory'] ?? []
          : [];

      for (var item in orderItems) {
        String productName = item['productName'];
        int requiredQuantity = item['quantity'];

        var product = inventoryData.firstWhere(
          (inventoryItem) => inventoryItem['productId'] == productName,
          orElse: () => null,
        );

        if (product != null) {
          // Reduce existing product quantity
          product['quantity'] -= requiredQuantity;
          // Remove the product if quantity is zero or less
          if (product['quantity'] <= 0) {
            inventoryData.remove(product);
          }
        } else {
          // If product is not found in the inventory, handle the error or add logging
          print('Product $productName not found in inventory.');
        }
      }

      await inventoryRef.update({'inventory': inventoryData});
      print('Updated employee inventory for $employeeEmail successfully');
    } catch (e) {
      print('Error updating employee inventory: $e');
    }
  }

  Future<void> sendAcceptedByToOrder(
      String orderId, List<dynamic> orderItems) async {
    bool hasEnoughInventory =
        await checkEmployeeInventory(currentUserEmail, orderItems);

    if (!hasEnoughInventory) {
      // Show a message to the user that there's not enough inventory
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สินค้าที่มีไม่เพียงพอในการกดรับออร์เดอร์')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Orders_list')
          .doc(orderId)
          .update({
        'acceptedBy': currentUserEmail,
        'deliveryStatus': 'pending', // Update delivery status to pending
      });
      print('ส่ง acceptedBy ไปยัง order $orderId เรียบร้อยแล้ว');

      // Set button color to green after successful operation
      setState(() {
        sendAcceptedByButtonColor = Colors.green;
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการส่ง acceptedBy ไปยัง order $orderId: $e');
    }
  }

  Future<void> setAcceptedByToWaiting(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders_list')
          .doc(orderId)
          .update({
        'acceptedBy': 'waiting',
      });
      print('ตั้งค่า acceptedBy เป็น "waiting" เรียบร้อยแล้ว');
    } catch (e) {
      print('เกิดข้อผิดพลาดในการตั้งค่า acceptedBy เป็น "waiting": $e');
    }
  }

  Color getDeliveryStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return Colors.grey; // สีเทา
      case 'pending':
        return Colors.yellow; // สีเหลือง
      case 'Paid':
        return Colors.green; // สีเขียว
      default:
        return Colors.grey; // ค่าเริ่มต้น สีเทา
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FetchDataOrder>>(
      future: _Orders_list,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        List<FetchDataOrder> Orders_list = snapshot.data ?? [];
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...Orders_list.map((order) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รหัสคำสั่งซื้อ: ${order.orderId}',
                            style: TextStyle(fontSize: 16)),
                        Text('ที่อยู่: ${order.address}',
                            style: TextStyle(fontSize: 16)),
                        Text('ชื่ออลูกค้า: ${order.customerName}',
                            style: TextStyle(fontSize: 16)),
                        Text('เบอร์โทรลูกค้า: ${order.PhoneNumber}',
                            style: TextStyle(fontSize: 16)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          itemBuilder: (context, index) {
                            var item = order.items[index];
                            var itemName = item['productName'] ??
                                'รายการสินค้าไม่ทราบชื่อ';
                            var itemQuantity =
                                item['quantity'] ?? 'ไม่ทราบจำนวน';
                            return ListTile(
                              title: Text('ชื่อสินค้า: $itemName'),
                              subtitle: Text('จำนวน: $itemQuantity'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleIconButton(
                    icon: Icons.map,
                    onPressed: () {
                      if (Orders_list.isNotEmpty) {
                        launchGoogleMaps(Orders_list.first.address);
                      }
                    },
                  ),
                  CircleIconButton(
                    icon: Icons.delivery_dining,
                    color: Colors.green,
                    onPressed: deliveryStatus == 'Paid'
                        ? null
                        : () {
                            if (Orders_list.isNotEmpty) {
                              updateDeliveryStatusAndRecordSale(
                                  Orders_list.first.orderId,
                                  context,
                                  Orders_list.first.items);
                            }
                          },
                  ),
                  CircleIconButton(
                    icon: Icons.check,
                    color: getDeliveryStatusColor(
                        Orders_list.first.deliveryStatus),
                    onPressed: () {
                      if (Orders_list.isNotEmpty) {
                        sendAcceptedByToOrder(
                            Orders_list.first.orderId, Orders_list.first.items);
                      }
                    },
                  ),
                  CircleIconButton(
                    icon: Icons.clear,
                    color: Colors.red,
                    onPressed: () {
                      if (Orders_list.isNotEmpty) {
                        setAcceptedByToWaiting(Orders_list.first.orderId);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  CircleIconButton(
      {required this.icon, this.color = Colors.blue, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
