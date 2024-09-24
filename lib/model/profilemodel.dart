class DeliveryDriverProfile {
  String uid; // Generated 6-digit customer ID
  String name;
  String email;
  String phoneNumber;
  String vehicleType;
  String licenseNumber;
  String profileImageUrl; // Added to store profile image URL

  DeliveryDriverProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.vehicleType,
    required this.licenseNumber,
    this.profileImageUrl = '', // Initialize with an empty string
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory DeliveryDriverProfile.fromMap(Map<String, dynamic> map) {
    return DeliveryDriverProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}
