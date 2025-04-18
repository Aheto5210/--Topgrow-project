import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/custom_appbar.dart';

class FarmerHomeScreen extends StatelessWidget {
  static String id = 'farmer_home_screen';

  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          CustomAppbar(
            hintText: "Search for any product",
            controller: TextEditingController(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading products'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: product.imageUrls.isNotEmpty
                                  ? Image.network(
                                product.imageUrls.first,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.image_not_supported, size: 50)),
                              )
                                  : const Center(
                                child: Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'GH₵ ${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff3B8751),
                                          ),
                                        ),
                                        Text(
                                          product.size,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Color(0xffDA4240),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        product.location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
}

// // Product model to parse Firestore data
// class Product {
//   final String id;
//   final String name;
//   final double price;
//   final String category;
//   final String location;
//   final String size;
//   final List<String> imageUrls;
//
//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.category,
//     required this.location,
//     required this.size,
//     required this.imageUrls,
//   });
//
//   factory Product.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Product(
//       id: doc.id,
//       name: data['name'] ?? '',
//       price: (data['price'] as num?)?.toDouble() ?? 0.0,
//       category: data['category'] ?? '',
//       location: data['location'] ?? '',
//       size: data['size'] ?? '',
//       imageUrls: List<String>.from(data['imageUrls'] ?? []),
//     );
//   }

