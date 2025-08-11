import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String location;
  final String size;
  final List<String> imageUrls;
  final String? phoneNumber;
  final DateTime postedDate;
  final List<String> interestedBuyers;
  final String farmerId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.location,
    required this.size,
    required this.imageUrls,
     this.phoneNumber,
    required this.postedDate,
    this.interestedBuyers = const [],
    required this.farmerId,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      size: data['size'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      phoneNumber: data['phoneNumber'] as String?,
      postedDate: (data['postedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      interestedBuyers: List<String>.from(data['interestedBuyers'] ?? []),
      farmerId: data['farmerId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'location': location,
      'size': size,
      'imageUrls': imageUrls,
      'phoneNumber': phoneNumber,
      'postedDate': Timestamp.fromDate(postedDate),
      'interestedBuyers': interestedBuyers,
      'farmerId': farmerId,
    };
  }
}