import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // Define a variable to store the selected month
  String selectedMonth = '1'; // Default to January (1)

  // Thai month names
  List<String> thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการยอดขาย'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dropdown menu for selecting months
          DropdownButton<String>(
            value: selectedMonth,
            onChanged: (String? newValue) {
              setState(() {
                selectedMonth = newValue!;
              });
            },
            items: List.generate(12, (index) {
              return DropdownMenuItem<String>(
                value: (index + 1).toString(),
                child: Text(thaiMonths[index]),
              );
            }),
          ),
          // FutureBuilder for fetching sales summary
          FutureBuilder<Map<String, dynamic>>(
            future: fetchSalesSummary(selectedMonth),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('ไม่พบข้อมูลการขาย'));
              }

              // Display sales summary
              double totalSales = snapshot.data!['totalSales'] ?? 0;
              Map<String, int> productSummary = snapshot.data!['productSummary'] ?? {};

              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สรุปยอดขายตามสินค้า',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'ยอดขายรวม: \$${totalSales.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: productSummary.entries.map((entry) {
                        return Text(
                          '${entry.key}: ${entry.value} ขวด',
                          style: TextStyle(fontSize: 16),
                        );
                      }).toList(),
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          ),
          // StreamBuilder for fetching detailed sales data
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Orders_list')
                  .where('acceptedBy', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('ไม่พบข้อมูลการขาย'));
                }

                // Filter and display detailed sales data
                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
                  DateTime orderDate = doc['timestamp'].toDate();
                  return orderDate.month.toString() == selectedMonth;
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = filteredDocs[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'รหัสการสั่งซื้อ: ${data['orderId']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'ผู้ซื้อ: ${data['customerName']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'ผู้ขาย: ${data['acceptedBy']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'ยอดขาย: \$${data['totalPrice'].toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'วันที่ขาย: ${data['timestamp'].toDate().toString()}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8.0),
                            Divider(),
                            SizedBox(height: 8.0),
                            Text(
                              'รายการสินค้า:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: data['items'].length,
                              itemBuilder: (context, index) {
                                var item = data['items'][index];
                                var itemName = item['productName'] ?? 'ไม่ทราบชื่อสินค้า';
                                var itemQuantity = item['quantity'] ?? 'ไม่ทราบจำนวน';
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchSalesSummary(String selectedMonth) async {
    Map<String, int> productSummary = {};
    double totalSales = 0;

    try {
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('Orders_list')
          .where('acceptedBy', isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();

      for (DocumentSnapshot orderDoc in ordersSnapshot.docs) {
        Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
        DateTime orderDate = orderData['timestamp'].toDate();

        // Filter by selected month
        if (orderDate.month.toString() == selectedMonth) {
          List<dynamic> orderItems = orderData['items'];
          double totalPrice = (orderData['totalPrice'] ?? 0).toDouble();
          totalSales += totalPrice;

          for (var item in orderItems) {
            String productName = item['productName'];
            int quantity = item['quantity'] ?? 0;

            if (productSummary.containsKey(productName)) {
              productSummary[productName] = productSummary[productName]! + quantity;
            } else {
              productSummary[productName] = quantity;
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching sales summary: $e');
    }

    return {
      'productSummary': productSummary,
      'totalSales': totalSales,
    };
  }

  void main() {
    runApp(MaterialApp(
      home: SalesPage(),
    ));
  }
}
