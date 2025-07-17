import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_grow_project/models/product.dart';
import 'package:top_grow_project/screens/buyer_product_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerInterestScreen extends StatefulWidget {
  static String id = 'buyer_interest_screen';

  const BuyerInterestScreen({super.key});

  @override
  State<BuyerInterestScreen> createState() => _BuyerInterestScreenState();
}

class _BuyerInterestScreenState extends State<BuyerInterestScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  // Function to initiate phone call to farmer
  Future<void> _callFarmer(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  // Function to clear all buyer interests with confirmation dialog
  Future<void> _clearAllInterests(List<Product> products) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear'),
        content: const Text('Are you sure you want to clear all interested products?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      for (var product in products) {
        if (currentUser != null &&
            product.interestedBuyers.contains(currentUser!.uid)) {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(product.id)
              .update({
            'interestedBuyers': FieldValue.arrayRemove([currentUser!.uid]),
          });

          // Also remove from Interests collection
          await FirebaseFirestore.instance
              .collection('Interests')
              .where('buyerId', isEqualTo: currentUser!.uid)
              .where('productId', isEqualTo: product.id)
              .get()
              .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All interests cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing interests: $e')),
      );
    }
  }

  // Function to handle refresh logic
  Future<void> _refreshInterests() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Interested Products',
          style: TextStyle(
            fontFamily: 'qwerty',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff3B8751),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Interested Products:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final products = await _fetchProductsFromInterests(
                      (await FirebaseFirestore.instance
                          .collection('Interests')
                          .where('buyerId', isEqualTo: currentUser?.uid)
                          .get())
                          .docs,
                    );
                    await _clearAllInterests(products);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Interests')
                  .where('buyerId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                if (snapshot.data?.docs.isEmpty ?? true) {
                  return const Center(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Text('No interested products yet'),
                    ),
                  );
                }

                return FutureBuilder<List<Product>>(
                  future: _fetchProductsFromInterests(snapshot.data!.docs),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productSnapshot.hasError) {
                      return Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Text('Error: ${productSnapshot.error}'),
                        ),
                      );
                    }

                    if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                      return const Center(
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Text('No products found'),
                        ),
                      );
                    }

                    final products = productSnapshot.data!;

                    return RefreshIndicator(
                      onRefresh: _refreshInterests,
                      color: const Color(0xff3B8751),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          // Format the postedDate using DateFormat
                          String formattedDate;
                          if (product.postedDate is Timestamp) {
                            formattedDate = DateFormat('MMM d, yyyy').format(
                              (product.postedDate as Timestamp).toDate(),
                            );
                          } else {
                            formattedDate = DateFormat('MMM d, yyyy').format(DateTime.now());
                          }

                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              BuyerProductDetailsScreen.id,
                              arguments: product,
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrls.isNotEmpty
                                        ? product.imageUrls[0]
                                        : '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Date Posted: ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff3B8751),
                                            ),
                                          ),
                                          TextSpan(
                                            text: formattedDate,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                              style: const TextStyle(
                                                fontSize: 14,
                                                  overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => _callFarmer(context, product.phoneNumber),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff3B8751),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

  Future<List<Product>> _fetchProductsFromInterests(
      List<QueryDocumentSnapshot> interestDocs,
      ) async {
    final productIds = interestDocs.map((doc) => doc['productId'] as String).toList();
    if (productIds.isEmpty) return [];

    final List<Product> products = [];
    const batchSize = 10; // Firestore whereIn limit
    for (var i = 0; i < productIds.length; i += batchSize) {
      final batchIds = productIds.sublist(
        i,
        i + batchSize > productIds.length ? productIds.length : i + batchSize,
      );
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();
      products.addAll(productSnapshot.docs.map((doc) => Product.fromFirestore(doc)));
    }
    return products;
  }
}