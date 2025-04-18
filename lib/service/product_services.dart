import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

// Initialize Cloudinary for image uploads
final cloudinary = CloudinaryPublic('dklrlcqx3', 'mawule', cache: false);

// Service class for product-related operations (Firestore and Cloudinary).
class ProductService {
  // Fetches regions from the API.
  Future<List<String>> fetchRegions() async {
    try {
      final response = await http
          .get(Uri.parse(
          'https://regions-and-districts-in-ghana.onrender.com/regions'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['regions'] is List) {
          final List<dynamic> regions = data['regions'];
          return regions.map((region) => region['label'].toString()).toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load regions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load regions: $e');
    }
  }

  // Uploads multiple images to Cloudinary.
  Future<List<String>> uploadImages(List<XFile> pickedFiles) async {
    List<String> imageUrls = [];
    try {
      for (var file in pickedFiles) {
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'products',
            publicId: 'product${DateTime.now().toIso8601String()}_${file.name}',
          ),
        );
        imageUrls.add(response.secureUrl);
      }
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  // Saves or updates a product in Firestore.
  Future<void> saveProduct({
    required String name,
    required double price,
    required String category,
    required String location,
    required String size,
    required List<String> imageUrls,
    String? id,
  }) async {
    try {
      final data = {
        'name': name,
        'price': price,
        'category': category,
        'location': location,
        'size': size,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (id != null) {
        await FirebaseFirestore.instance.collection('products').doc(id).update(data);
      } else {
        await FirebaseFirestore.instance.collection('products').add(data);
      }
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  // Deletes a product from Firestore.
  Future<void> deleteProduct(String id) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}