import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DairyDunk/components/my_drawer.dart';
import 'package:DairyDunk/pages/deliverypage.dart';

// Define a class to hold order data
class Order {
  final String id;
  final String orderId;
  final String customerName;
  final double totalPrice;
  final String deliveryStatus; // Changed to String
  final String acceptedBy; // Changed field name

  Order({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.totalPrice,
    required this.deliveryStatus, // Updated constructor
    required this.acceptedBy, // Updated constructor
  });
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('Orders_list'); // Updated collection name

  late String currentUserEmail;
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
  }

  void getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserEmail = user.email!;
      isAdmin = user.email == 'admin@example.com'; // Example admin check
    } else {
      // Handle the case where user is not logged in
      currentUserEmail = '';
      isAdmin = false;
    }
  }

  String _formatPrice(double price) {
    return "\฿${price.toStringAsFixed(2)}";
  }

  String _getDeliveryStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'กำลังรอจัดส่ง';
      case 'pending':
        return 'รอการยืนยัน';
      case 'Paid':
        return 'จัดส่งแล้ว';
      case 'complete':
        return 'สำเร็จแล้ว';
      default:
        return 'สถานะไม่ทราบ';
    }
  }

  Color _getDeliveryStatusColor(String status) {
    switch (status) {
      case 'Paid':
      case 'complete':
        return Colors.green;
      case 'waiting':
      case 'pending':
      default:
        return Colors.red;
      
    }
  }

  List<String> dismissedOrderIds = []; // Track dismissed order IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('รายการสินค้า'),
            floating: true,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    // Refresh orders
                  });
                },
              ),
            ],
          ),
        ],
        body: StreamBuilder<QuerySnapshot>(
          stream: _collectionRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No orders found'));
            }

            final data = snapshot.requireData;

            // Map Firestore documents to Order objects
            List<Order> orders = data.docs.map((doc) {
              return Order(
                id: doc.id,
                customerName: doc['customerName'],
                orderId: doc['orderId'] ?? 'Unknown',
                totalPrice: doc['totalPrice'] ?? 0.0,
                deliveryStatus: doc['deliveryStatus'] ?? 'waiting', // Updated field name
                acceptedBy: doc['acceptedBy'] ?? '', // Updated field name
              );
            }).toList();

            // Filter orders based on visibility criteria
            var visibleOrders = orders.where((order) {
              // Show orders where current user is the acceptedBy or acceptedBy is "waiting"
              return order.acceptedBy == currentUserEmail || order.acceptedBy == 'waiting';
            }).toList();

            return ListView.builder(
              itemCount: visibleOrders.length,
              itemBuilder: (context, index) {
                var order = visibleOrders[index];

                return Dismissible(
                  key: Key(order.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      dismissedOrderIds.add(order.id);
                    });
                  },
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you want to dismiss this order?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DISMISS"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('รหัสการสั่งซื้อ: ${order.orderId}'),
                              Text('ลูกค้า: ${order.customerName}'),
                              Text('ราคารวม: ${_formatPrice(order.totalPrice)}'),
                              Text(
                                'สถานะการจัดส่ง: ${_getDeliveryStatusText(order.deliveryStatus)}',
                                style: TextStyle(
                                  color: _getDeliveryStatusColor(order.deliveryStatus),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delivery_dining_sharp),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliveryPage(orderId: order.orderId),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
