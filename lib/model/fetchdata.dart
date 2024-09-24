class FetchDataOrder {
  final String orderId;
  final String customerName;
  final String PhoneNumber;
  final double totalPrice;
  final String address;
  final List<Map<String, dynamic>> items;
  final String deliveryStatus;

  FetchDataOrder({
    required this.orderId,
    required this.customerName,
    required this.PhoneNumber,
    required this.totalPrice,
    required this.address,
    required this.items,
    required this.deliveryStatus,
  });

  factory FetchDataOrder.fromMap(Map<String, dynamic> data) {
    return FetchDataOrder(
      orderId: data['orderId'] as String,
      customerName: data['customerName'] as String,
      PhoneNumber: data['customerPhoneNumber'] as String,
      totalPrice: data['totalPrice'] as double,
      address: data['location'] as String,
      items: List<Map<String, dynamic>>.from(data['items']),
      deliveryStatus: data['deliveryStatus'] as String,
    );
  }
}
