import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_grow_project/models/product.dart';

class ViewsScreen extends StatefulWidget {
  static String id = 'views_screen';

  const ViewsScreen({super.key});

  @override
  State<ViewsScreen> createState() => _ViewsScreenState();
}

class _ViewsScreenState extends State<ViewsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  // Function to clear all buyer interests with confirmation dialog
  Future<void> _clearAllInterests(
      List<Map<String, dynamic>> buyerInterests,
      ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear'),
        content: const Text('Are you sure you want to clear all buyer interests?'),
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
      for (var interest in buyerInterests) {
        final product = interest['product'] as Product;
        for (var buyerId in product.interestedBuyers) {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(product.id)
              .update({
            'interestedBuyers': FieldValue.arrayRemove([buyerId]),
          });
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All buyer interests cleared')),
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
          'Views',
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
                  'Viewed Products:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final buyerInterests = await _fetchBuyerDetails(
                      (await FirebaseFirestore.instance
                          .collection('products')
                          .where('farmerId', isEqualTo: currentUser?.uid)
                          .get())
                          .docs
                          .map((doc) => Product.fromFirestore(doc))
                          .where(
                            (product) => product.interestedBuyers.isNotEmpty,
                      )
                          .toList(),
                    );
                    await _clearAllInterests(buyerInterests);
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
                  .collection('products')
                  .where('farmerId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productSnapshot.hasError) {
                  return Center(child: Text('Error: ${productSnapshot.error}'));
                }

                if (productSnapshot.data?.docs.isEmpty ?? true) {
                  return const Center(child: Text('No products found'));
                }

                final products = productSnapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .where((product) => product.interestedBuyers.isNotEmpty)
                    .toList();

                if (products.isEmpty) {
                  return const Center(child: Text('No buyers interested yet'));
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchBuyerDetails(products),
                  builder: (context, buyerSnapshot) {
                    if (buyerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (buyerSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${buyerSnapshot.error}'),
                      );
                    }

                    if (!buyerSnapshot.hasData || buyerSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No buyer details found'),
                      );
                    }

                    final buyerInterests = buyerSnapshot.data!;

                    return RefreshIndicator(
                      onRefresh: _refreshInterests,
                      color: const Color(0xff3B8751),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: buyerInterests.length,
                        itemBuilder: (context, index) {
                          final interest = buyerInterests[index];
                          final product = interest['product'] as Product;

                          // Format the postedDate using DateFormat
                          String formattedDate;
                          if (product.postedDate is Timestamp) {
                            formattedDate = DateFormat('MMM d, yyyy').format(
                              (product.postedDate as Timestamp).toDate(),
                            );
                          } else {
                            formattedDate = DateFormat('MMM d, yyyy')
                                .format(DateTime.now());
                          }

                          return Card(
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff3B8751),
                                          ),
                                        ),
                                        TextSpan(
                                          text: formattedDate,
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xff3B8751),
                                              borderRadius:
                                              BorderRadius.circular(5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            child: Text(
                                              'Views: ${product.interestedBuyers.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
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

  Future<List<Map<String, dynamic>>> _fetchBuyerDetails(
      List<Product> products,
      ) async {
    final interests = <Map<String, dynamic>>[];

    for (var product in products) {
      for (var buyerId in product.interestedBuyers) {
        final buyerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(buyerId)
            .get();
        final buyer = buyerDoc.exists
            ? buyerDoc.data() as Map<String, dynamic>
            : {'name': 'Unknown', 'phoneNumber': null};

        interests.add({'product': product, 'buyer': buyer});
      }
    }

    return interests;
  }
}