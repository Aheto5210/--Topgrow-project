import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String productName;
  final double price;
  final String location;
  final int quantity;
  final String status;
  final String buyerId;
  final String farmerId;
  final String productId;
  final DateTime createdAt;
  final double totalPrice;
  final String reference; // Optional for COD

  Order({
    required this.id,
    required this.productName,
    required this.price,
    required this.location,
    required this.quantity,
    required this.status,
    required this.buyerId,
    required this.farmerId,
    required this.productId,
    required this.createdAt,
    required this.totalPrice,
    required this.reference,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      productName: data['productName'] ?? '',
      price: (data['price'] as num).toDouble(),
      location: data['location'] ?? '',
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      buyerId: data['buyerId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      productId: data['productId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      reference: data['reference'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productName': productName,
      'price': price,
      'location': location,
      'quantity': quantity,
      'status': status,
      'buyerId': buyerId,
      'farmerId': farmerId,
      'productId': productId,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalPrice': totalPrice,
      'reference': reference, // new
    };
  }
}
