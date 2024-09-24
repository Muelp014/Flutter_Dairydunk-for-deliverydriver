class DeliveryReport {
  final String orderId;
  final String customerName;
  final bool deliveryStatus;
  final String acceptedBy;

  DeliveryReport({
    required this.orderId,
    required this.customerName,
    required this.deliveryStatus,
    required this.acceptedBy,
  });

  factory DeliveryReport.fromMap(Map<String, dynamic> map) {
    return DeliveryReport(
      orderId: map['orderId'],
      customerName: map['customerName'],
      deliveryStatus: map['deliveryStatus'],
      acceptedBy: map['acceptedBy'],
    );
  }
}
