import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDataScreen extends StatelessWidget {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('your_collection_name');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _collectionRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              final docData = data.docs[index].data() as Map<String, dynamic>;
              final fieldName = docData['field_name'];
              final deliveryStatus = docData['deliveryStatus'];

            },
          );
        },
      ),
    );
  }
}
