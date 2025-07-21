import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:top_grow_project/models/product.dart';
import 'package:top_grow_project/screens/buyer_product_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/interest_service.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String category;

  const CategoryDetailScreen({super.key, required this.category});

  // Function to mark/unmark interest
  Future<void> _markInterested(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to mark interest')),
      );
      return;
    }

    try {
      final interestService = InterestService();
      final isNowInterested = await interestService.toggleInterest(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            isNowInterested
                ? 'Product marked as interested'
                : 'Product unmarked from interests',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking interest: $e')),
      );
    }
  }

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

  // Function to check if a product is marked as interested by the user
  Future<bool> _checkInterestStatus(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final interestRef = FirebaseFirestore.instance
        .collection('Interests')
        .doc('${user.uid}_$productId');
    final interestDoc = await interestRef.get();
    return interestDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products Under $category',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff3B8751),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading products'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff3B8751)),
              );
            }
            final products =
            snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();
            if (products.isEmpty) {
              return const Center(child: Text('No products in this category'));
            }

            return GridView.builder(
              padding: EdgeInsets.all(10),
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
                    BuyerProductDetailsScreen.id,
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
                                      errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                          ) =>
                                      const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
                                      ),
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
                                    children: [
                                      Text(
                                        'GH₵ ${product.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff3B8751),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Color(0xffDA4240),
                                  ),
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
                                  Text(
                                    product.size,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _callFarmer(context, product.phoneNumber),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xff3B8751),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.phone_in_talk_outlined,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Call',
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
                                  ),
                                  FutureBuilder<bool>(
                                    future: _checkInterestStatus(product.id),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Icon(
                                          Icons.favorite_border,
                                          color: Colors.grey,
                                        );
                                      }
                                      final isInterested = snapshot.data ?? false;
                                      return IconButton(
                                        onPressed: () =>
                                            _markInterested(context, product),
                                        icon: Icon(
                                          isInterested
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isInterested ? Colors.red : Colors.grey,
                                        ),
                                      );
                                    },
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
            );
          },
        ),
      ),
    );
  }
}