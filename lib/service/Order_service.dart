import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_grow_project/models/order.dart';
import 'package:top_grow_project/models/product.dart';

class OrderService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  /// Creates a new order for the given product and quantity.
  /// Includes fetching buyer's name and contact from users collection.
  Future<void> createOrder(
      Product product,
      int quantity, {
        String buyerName = '',
        String buyerContact = '',
      }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Validate product fields
    if (product.name.isEmpty ||
        product.price <= 0 ||
        product.location.isEmpty ||
        product.farmerId.isEmpty ||
        product.id.isEmpty) {
      throw Exception('Invalid product details');
    }

    if (quantity <= 0) {
      throw Exception('Quantity must be at least 1');
    }

    // If buyerName or buyerContact not passed, fetch from Firestore
    String finalBuyerName = buyerName;
    String finalBuyerContact = buyerContact;
    if (buyerName.isEmpty || buyerContact.isEmpty) {
      final buyerDoc = await _firestore.collection('users').doc(userId).get();
      if (!buyerDoc.exists) {
        throw Exception('Buyer user data not found');
      }
      final buyerData = buyerDoc.data();
      if (buyerData == null) {
        throw Exception('Buyer user data is empty');
      }
      finalBuyerName = buyerData['fullName'] ?? 'Unknown Buyer';
      finalBuyerContact = buyerData['phoneNumber'] ?? 'No Contact';
    }

    final totalPrice = product.price * quantity;

    final order = Order(
      id: '', // Firestore auto-generated ID
      productName: product.name,
      price: product.price,
      location: product.location,
      quantity: quantity,
      status: 'pending_cod', // Default status for COD
      buyerId: userId,
      farmerId: product.farmerId,
      productId: product.id,
      createdAt: DateTime.now(),
      totalPrice: totalPrice,
      reference: '', // Empty for COD

    );

    try {
      await _firestore.collection('orders').add(order.toFirestore());
    } on firestore.FirebaseException catch (e) {
      throw Exception('Failed to create order: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error creating order: $e');
    }
  }

  /// Fetches all orders placed by current buyer.
  Future<List<Order>> getUserOrders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } on firestore.FirebaseException catch (e) {
      throw Exception('Failed to fetch orders: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching orders: $e');
    }
  }

  /// Fetches all orders for current farmer.
  Future<List<Order>> getFarmerOrders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('farmerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } on firestore.FirebaseException catch (e) {
      throw Exception('Failed to fetch farmer orders: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching farmer orders: $e');
    }
  }
}
