import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';
import '../models/product.dart';
import '../widgets/product_list_item.dart';

class SearchResults extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onRetry;

  const SearchResults({
    super.key,
    required this.searchQuery,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
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
                    fontSize:
                    textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SearchConstants.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(SearchConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                      textScaler.scale(screenWidth * 0.04).clamp(12, 16),
                      fontFamily: 'qwerty',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();

        final filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              product.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
               product.price.toString().contains(searchQuery.toLowerCase());
        }).toList();

        return filteredProducts.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: screenWidth * 0.12,
                color: Colors.black54,
              ),
              SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
              Text(
                'No products found',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontSize:
                  textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth * 0.05)
                  .clamp(SearchConstants.standardPadding, 32),
              vertical: (screenHeight * 0.02).clamp(8, 16),
            ),
            child: Column(
              children: filteredProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return Column(
                  children: [
                    ProductListItem(product: product),
                    if (index < filteredProducts.length - 1)
                      Divider(
                        height: (screenHeight * 0.02).clamp(8, 16),
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}