import 'package:cloud_firestore/cloud_firestore.dart';

// Product model to parse Firestore data.
class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String location;
  final String size;
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.location,
    required this.size,
    required this.imageUrls,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      size: data['size'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }
}