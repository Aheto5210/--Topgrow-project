import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:top_grow_project/models/product.dart';
import 'package:top_grow_project/screens/product_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_appbar.dart';

class FarmerHomeScreen extends StatelessWidget {
  static String id = 'farmer_home_screen';

  const FarmerHomeScreen({super.key});

  // Function to initiate phone call
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

  // Function to handle refresh logic
  Future<void> _refreshProducts() async {
    // Since StreamBuilder is already listening to Firestore, we don't need to manually refetch.
    // This can be used to force a UI refresh or handle additional logic if needed.
    // For now, it simply delays slightly to give feedback to the user.
    await Future.delayed(const Duration(milliseconds: 500));
  }

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
                  return const Center(child: CircularProgressIndicator(color: Color(0xff3B8751)));
                }
                final products = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .toList();
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet'));
                }

                return RefreshIndicator(
                  onRefresh: _refreshProducts,
                  color: const Color(0xff3B8751), // Match the app's theme color
                  child: GridView.builder(
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
                      final PageController pageController = PageController();
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          ProductDetailsScreen.id,
                          arguments: product,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffEAB916)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      controller: pageController,
                                      itemCount: product.imageUrls.isNotEmpty
                                          ? product.imageUrls.length
                                          : 1,
                                      itemBuilder: (context, pageIndex) {
                                        return ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(10),
                                          ),
                                          child: product.imageUrls.isNotEmpty
                                              ? Image.network(
                                            product.imageUrls[pageIndex].replaceFirst(
                                              '/upload/',
                                              '/upload/w_300,c_fill,q_auto,f_auto,dpr_auto/',
                                            ),
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                              : const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (product.imageUrls.length > 1)
                                      Positioned(
                                        bottom: 8,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: SmoothPageIndicator(
                                            controller: pageController,
                                            count: product.imageUrls.length,
                                            effect: const JumpingDotEffect(
                                              dotHeight: 8,
                                              dotWidth: 8,
                                              activeDotColor: Color(0xff3B8751),
                                              dotColor: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
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
                                        // Product Name
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
                                        // Price and Size in a Container
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffD9D9D9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                'GH₵ ${product.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff3B8751),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                product.size,
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
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _callFarmer(context, product.phoneNumber),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xff3B8751),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}