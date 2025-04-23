import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ProductDetailsScreen.id,
          arguments: product,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: (screenHeight * 0.01).clamp(4, 8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: SearchConstants.primaryGreen,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: (screenWidth * 0.15).clamp(50, 60),
                  height: (screenWidth * 0.15).clamp(50, 60),
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.local_offer,
                    size: 30,
                    color: SearchConstants.primaryGreen,
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
                  color: SearchConstants.primaryGreen,
                ),
              ),
            ),
            SizedBox(width: (screenWidth * 0.03).clamp(8, 12)),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}