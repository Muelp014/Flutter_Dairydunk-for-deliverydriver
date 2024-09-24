import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeInventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คลังสินค้าของพนักงาน'),
      ),
      body: EmployeeInventoryList(),
    );
  }
}

class EmployeeInventoryList extends StatefulWidget {
  @override
  _EmployeeInventoryListState createState() => _EmployeeInventoryListState();
}

class _EmployeeInventoryListState extends State<EmployeeInventoryList> {
  late Future<List<InventoryItem>> _inventoryItems;

  @override
  void initState() {
    super.initState();
    _inventoryItems = fetchEmployeeInventory();
  }

  Future<List<InventoryItem>> fetchEmployeeInventory() async {
    List<InventoryItem> inventoryItems = [];
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('employeeInventory')
            .doc(currentUserEmail)
            .get();

        if (snapshot.exists) {
          List<dynamic>? inventoryData = snapshot.data()?['inventory'];
          if (inventoryData != null) {
            for (var item in inventoryData) {
              InventoryItem inventoryItem = InventoryItem.fromMap(item);
              if (inventoryItem.quantity > 0) { // Filter out items with quantity 0
                inventoryItems.add(inventoryItem);
              }
            }
          }
        }
      } catch (e) {
        print('Error fetching employee inventory: $e');
      }
    }
    return inventoryItems;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InventoryItem>>(
      future: _inventoryItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        List<InventoryItem> inventoryItems = snapshot.data ?? [];
        if (inventoryItems.isEmpty) {
          return Center(child: Text('ไม่มีข้อมูลสินค้าในคลัง'));
        }
        return ListView.builder(
          itemCount: inventoryItems.length,
          itemBuilder: (context, index) {
            InventoryItem item = inventoryItems[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(item.productName),
                subtitle: Text('จำนวน: ${item.quantity}'),
              ),
            );
          },
        );
      },
    );
  }
}

class InventoryItem {
  final String productName;
  final int quantity;

  InventoryItem({required this.productName, required this.quantity});

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      productName: map['productId'] as String,
      quantity: map['quantity'] as int,
    );
  }
}
