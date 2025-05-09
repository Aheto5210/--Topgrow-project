import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_grow_project/models/product.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerInterestScreen extends StatefulWidget {
  static String id = 'buyer_interest_screen';
  const BuyerInterestScreen({super.key});

  @override
  State<BuyerInterestScreen> createState() => _BuyerInterestScreenState();
}

class _BuyerInterestScreenState extends State<BuyerInterestScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interested Products'),
        backgroundColor: const Color(0xff3B8751),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Interests')
            .where('buyerId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(child: Text('No interested products yet'));
          }

          return FutureBuilder<List<Product>>(
            future: _fetchProductsFromInterests(snapshot.data!.docs),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productSnapshot.hasError) {
                return Center(child: Text('Error: ${productSnapshot.error}'));
              }

              if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              final products = productSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrls.isNotEmpty
                                      ? product.imageUrls[0]
                                      : '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Posted: ${DateFormat('MMM d, y').format(product.postedDate)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(0xffDA4240),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.location,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (product.phoneNumber == null ||
                                      product.phoneNumber!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Phone number not available')),
                                    );
                                    return;
                                  }
                                  final Uri phoneUri =
                                  Uri(scheme: 'tel', path: product.phoneNumber);
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Could not launch phone call')),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff3B8751),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.phone_in_talk_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Call Farmer',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Product>> _fetchProductsFromInterests(
      List<QueryDocumentSnapshot> interestDocs) async {
    final productIds = interestDocs.map((doc) => doc['productId'] as String).toList();

    if (productIds.isEmpty) {
      return [];
    }

    // Fetch products using whereIn (limited to 10 IDs by Firestore)
    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .get();

    return productSnapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();
  }
}