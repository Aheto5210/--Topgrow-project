import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String location;
  final String size;
  final List<String> imageUrls;
  final String? phoneNumber; // Farmer's phone number
  final DateTime postedDate; // Date product was posted

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
  });

  // Convert Firestore document to Product
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
      phoneNumber: data['phoneNumber'],
      postedDate: (data['postedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Product to Firestore map
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
    };
  }
}