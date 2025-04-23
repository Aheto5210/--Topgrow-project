import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../service/product_services.dart';
import '../widgets/product_form_sheet.dart';

// Uses Firestore to stream products and a modal sheet for product forms.
class ProductScreen extends StatefulWidget {
  static const String id = 'product_screen';
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  String? _deletingProductId;

  // Color palette for consistency
  static const Color primaryGreen = Color(0xff3B8751);
  static const Color accentYellow = Color(0xffEAB916);
  static const Color errorRed = Color(0xffDA4240);

  // Standard padding and border radius
  static const double borderRadius = 12.0;

  // Shows the product form modal for adding or editing
  void _showProductForm(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) => ProductFormSheet(product: product),
    );
  }

  // Confirms and deletes a product
  Future<void> _deleteProduct(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _deletingProductId = id;
      });
      try {
        await _productService.deleteProduct(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "$name" deleted successfully'),
              backgroundColor: primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _deletingProductId = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, size),
          SizedBox(height: size.height * 0.015),
          _buildCreateButton(context, size),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 16, color: errorRed),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => setState(() {}), // Retry
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xff3B8751)));
                }
                final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return RefreshIndicator(

                  onRefresh: () async {
                    setState(() {}); // Trigger rebuild to refresh data
                  },
                  color: primaryGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.all(size.width * 0.04),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () => _showProductForm(context, product: product),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              // Product image
                              product.imageUrls.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrls.first,
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const CircularProgressIndicator(
                                    color: primaryGreen,
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.image_not_supported,
                                    size: size.width * 0.12,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : Icon(
                                Icons.image_not_supported,
                                size: size.width * 0.12,
                                color: Colors.grey,
                              ),
                              SizedBox(width: size.width * 0.03),
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: (size.width * 0.04).clamp(14, 16),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'qwerty',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.location,
                                      style: TextStyle(
                                        fontSize: (size.width * 0.035).clamp(12, 14),
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              // Update button
                              InkWell(
                                onTap: () => _showProductForm(context, product: product),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02,
                                    vertical: size.width * 0.02,
                                  ),
                                  margin: EdgeInsets.only(right: size.width * 0.02),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: accentYellow),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: accentYellow,
                                        size: size.width * 0.045,
                                      ),
                                      SizedBox(width: size.width * 0.01),
                                      Text(
                                        'Update',
                                        style: TextStyle(
                                          color: accentYellow,
                                          fontSize: (size.width * 0.035).clamp(12, 14),
                                          fontFamily: 'qwerty',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Delete button
                              InkWell(
                                onTap: _deletingProductId == product.id
                                    ? null
                                    : () => _deleteProduct(product.id, product.name),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02,
                                    vertical: size.width * 0.02,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: errorRed),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      _deletingProductId == product.id
                                          ? SizedBox(
                                        width: size.width * 0.045,
                                        height: size.width * 0.045,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(errorRed),
                                        ),
                                      )
                                          : Icon(
                                        Icons.delete,
                                        color: errorRed,
                                        size: size.width * 0.045,
                                      ),
                                      SizedBox(width: size.width * 0.01),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: errorRed,
                                          fontSize: (size.width * 0.035).clamp(12, 14),
                                          fontFamily: 'qwerty',
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.12, // Responsive height
      color: primaryGreen,
      child: Center(
        child: Text(
          'Products/Items',
          style: TextStyle(
            fontFamily: 'qwerty',
            fontWeight: FontWeight.w600,
            fontSize: (size.width * 0.05).clamp(18, 20),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: InkWell(
        onTap: () => _showProductForm(context),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: size.height * 0.06,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: accentYellow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.white),
              SizedBox(width: size.width * 0.02),
              Text(
                'Create A New Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: (size.width * 0.045).clamp(16, 18),
                  fontFamily: 'qwerty',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}