// filter_results.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/models/product.dart';
import 'package:top_grow_project/screens/product_details_screen.dart';

class FilterResults extends StatelessWidget {
  final bool isSearchPressed;
  final String nameQuery;
  final String locationQuery;

  const FilterResults({
    super.key,
    required this.isSearchPressed,
    required this.nameQuery,
    required this.locationQuery,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    if (!isSearchPressed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list,
              size: screenWidth * 0.12,
              color: Colors.black54,
            ),
            SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
            Text(
              'Start filtering products',
              style: TextStyle(
                fontFamily: 'qwerty',
                fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Placeholder shimmer items
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (screenWidth * 0.05).clamp(16, 32),
                  vertical: (screenHeight * 0.01).clamp(4, 8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: (screenWidth * 0.15).clamp(50, 60),
                      height: (screenWidth * 0.15).clamp(50, 60),
                      color: Colors.white,
                    ),
                    SizedBox(width: (screenWidth * 0.03).clamp(8, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth * 0.5,
                            height: screenHeight * 0.02,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: screenWidth * 0.3,
                            height: screenHeight * 0.015,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading products',
                  style: TextStyle(
                    fontFamily: 'qwerty',
                    fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => (context as Element).markNeedsBuild(), // Retry
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textScaler.scale(screenWidth * 0.04).clamp(12, 16),
                      fontFamily: 'qwerty',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Convert Firestore docs to Product objects
        final products = snapshot.data!.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();

        // Filter products by name and location
        final filteredProducts = products.where((product) {
          final nameMatch = nameQuery.isEmpty ||
              product.name.toLowerCase().contains(nameQuery);
          final locationMatch = locationQuery.isEmpty ||
              product.location.toLowerCase().contains(locationQuery);
          return nameMatch && locationMatch;
        }).toList();

        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_off,
                  size: screenWidth * 0.12,
                  color: Colors.black54,
                ),
                SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontFamily: 'qwerty',
                    fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth * 0.05).clamp(16, 32),
            vertical: (screenHeight * 0.02).clamp(8, 16),
          ),
          itemCount: filteredProducts.length,
          separatorBuilder: (context, index) => Divider(
            height: (screenHeight * 0.02).clamp(8, 16),
            color: Colors.grey[300],
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ProductDetailsScreen.id,
                  arguments: product,
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: product.imageUrls.first,
                      width: (screenWidth * 0.15).clamp(50, 60),
                      height: (screenWidth * 0.15).clamp(50, 60),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: primaryGreen,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: (screenWidth * 0.15).clamp(50, 60),
                        height: (screenWidth * 0.15).clamp(50, 60),
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.local_offer,
                          size: 30,
                          color: primaryGreen,
                        ),
                      ),
                    )
                        : Container(
                      width: (screenWidth * 0.15).clamp(50, 60),
                      height: (screenWidth * 0.15).clamp(50, 60),
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.local_offer,
                        size: 30,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: (screenWidth * 0.03).clamp(8, 12)),
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontFamily: 'qwerty',
                            fontSize:
                            textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                        ),
                        SizedBox(height: (screenHeight * 0.005).clamp(4, 8)),
                        Text(
                          product.location,
                          style: TextStyle(
                            fontFamily: 'qwerty',
                            fontSize:
                            textScaler.scale(screenWidth * 0.04).clamp(12, 16),
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
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
    );
  }
}