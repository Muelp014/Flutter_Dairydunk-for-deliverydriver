import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DeliveryDriverProfileScreen extends StatefulWidget {
  @override
  _DeliveryDriverProfileScreenState createState() => _DeliveryDriverProfileScreenState();
}

class _DeliveryDriverProfileScreenState extends State<DeliveryDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  String? _email;
  String? _profileImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User is logged in: ${user.uid}');
      _email = user.email; // Set the email for display
      _emailController.text = _email!;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(_email) // Use the email as the document ID
          .get();

      if (doc.exists) {
        print('Document exists for user: ${user.uid}');
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Data from Firestore: $data');
        
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _vehicleTypeController.text = data['vehicleType'] ?? '';
          _licenseNumberController.text = data['licenseNumber'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
        });
      } else {
        print('No document found for user: ${user.uid}');
      }
    } else {
      print('No user is logged in');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
  if (_imageFile != null) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in')),
      );
      return;
    }

    try {
      String fileName = 'profile_pictures/${user.uid}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(_imageFile!);
      TaskSnapshot taskSnapshot = await uploadTask;
      _profileImageUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }
}

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _uploadImage(); // Upload the image before saving the profile

        Map<String, dynamic> profileData = {
          'name': _nameController.text,
          'email': _email!, // Ensure email remains the same as logged-in email
          'phoneNumber': _phoneNumberController.text,
          'vehicleType': _vehicleTypeController.text,
          'licenseNumber': _licenseNumberController.text,
          'profileImageUrl': _profileImageUrl,
        };

        await FirebaseFirestore.instance
            .collection('Employee')
            .doc(_email) // Use the email as the document ID
            .set(profileData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile saved successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delivery Driver Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                    child: _imageFile == null && _profileImageUrl == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  enabled: false, // Email should not be editable
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _vehicleTypeController,
                  decoration: InputDecoration(labelText: 'Vehicle Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your vehicle type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _licenseNumberController,
                  decoration: InputDecoration(labelText: 'License Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your license number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
