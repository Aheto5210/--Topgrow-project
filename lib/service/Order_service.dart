import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_grow_project/models/order.dart';
import 'package:top_grow_project/models/product.dart';

class OrderService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  String? _paymentMethod;
  String? _paymentReference;

  /// Setter for payment details from UI or payment process
  void setPaymentDetails(String paymentMethod, String? paymentReference) {
    _paymentMethod = paymentMethod;
    _paymentReference = paymentReference;
  }

  /// Creates a new order for the given product and quantity.
  /// Does NOT store buyer name/contact, only buyerId from Auth.
  Future<void> createOrder(Product product, int quantity) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

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

    final totalPrice = product.price * quantity;

    final order = Order(
      id: '', // Firestore auto-generated ID
      productName: product.name,
      price: product.price,
      location: product.location,
      quantity: quantity,
      status: _paymentMethod == 'Pay Now' ? 'pending' : 'pending_cod',  // Changed here
      buyerId: userId,
      farmerId: product.farmerId,
      productId: product.id,
      createdAt: DateTime.now(),
      totalPrice: totalPrice,
      reference: _paymentReference ?? '',
    );

    try {
      print('Creating order for user: $userId with status: ${order.status}');
      await _firestore.collection('orders').add(order.toFirestore());
      print('Order created successfully');
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
