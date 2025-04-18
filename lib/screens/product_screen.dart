
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

  //Shows the product form modal for adding or editing.
  void _showProductForm(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProductFormSheet(product: product),
    );
  }

  // Confirms and deletes a product.
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
              style: TextStyle(color: Colors.red),
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
              backgroundColor: const Color(0xff3B8751),
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet'));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(size.width * 0.04),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: product.imageUrls.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrls.first,
                                width: size.width * 0.12,
                                height: size.width * 0.12,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.image_not_supported, size: size.width * 0.12),
                              ),
                            )
                                : Icon(Icons.image_not_supported, size: size.width * 0.12),
                            title: Text(
                              product.name,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              product.location,
                              overflow: TextOverflow.visible,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () => _showProductForm(context, product: product),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.02,
                              vertical: 8,
                            ),
                            margin: EdgeInsets.only(right: size.width * 0.02),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xffEAB916)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: const Color(0xffEAB916),
                                  size: size.width * 0.045,
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  'Update',
                                  style: TextStyle(
                                    color: const Color(0xffEAB916),
                                    fontSize: (size.width * 0.035).clamp(12, 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _deletingProductId == product.id
                              ? null
                              : () => _deleteProduct(product.id, product.name),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xffDA4240)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                _deletingProductId == product.id
                                    ? SizedBox(
                                  width: size.width * 0.045,
                                  height: size.width * 0.045,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Color(0xffDA4240)),
                                  ),
                                )
                                    : Icon(
                                  Icons.delete,
                                  color: const Color(0xffDA4240),
                                  size: size.width * 0.045,
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: const Color(0xffDA4240),
                                    fontSize: (size.width * 0.035).clamp(12, 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.15,
      color: const Color(0xff3B8751),
      child: const Center(
        child: Text(
          'Products/Items',
          style: TextStyle(
            fontFamily: 'qwerty',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      child: InkWell(
        onTap: () => _showProductForm(context),
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: size.height * 0.06,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xffEAB916),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Create A New Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
