import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_grow_project/models/order.dart';
import 'package:top_grow_project/buyer_bot_nav.dart';

class OrderScreen extends StatefulWidget {
  static const String id = 'order_screen';

  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Add this key to control the RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  String _formatStatus(String status) {
    switch (status) {
      case 'pending_cod':
        return 'Pending (Cash on Delivery)';
      case 'pending':
        return 'Pending Payment';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.capitalize();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending_cod':
      case 'pending':
        return Colors.orange.shade800;
      case 'completed':
        return Colors.teal.shade700;
      case 'cancelled':
        return Colors.redAccent.shade700;
      default:
        return Colors.grey;
    }
  }

  // Pull to refresh handler: just trigger setState to refresh StreamBuilder
  Future<void> _refreshOrders() async {
    setState(() {
      // Just rebuilding triggers StreamBuilder to reload fresh data
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Orders',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xff3B8751),
        ),
        body: const Center(
          child: Text(
            'Please sign in to view your orders',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, BuyerBotNav.id);
            },
          ),
          title: const Text(
            'My Orders',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff3B8751),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: StreamBuilder<firestore.QuerySnapshot>(
          stream: firestore.FirebaseFirestore.instance
              .collection('orders')
              .where('buyerId', isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff3B8751)),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            final allOrders = snapshot.data!.docs
                .map((doc) => Order.fromFirestore(doc))
                .toList();

            // Sort by createdAt descending locally
            allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final pendingOrders = allOrders
                .where((o) => o.status == 'pending' || o.status == 'pending_cod')
                .toList();
            final completedOrders =
            allOrders.where((o) => o.status == 'completed').toList();
            final cancelledOrders =
            allOrders.where((o) => o.status == 'cancelled').toList();

            return TabBarView(
              children: [
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshOrders,
                  child: _buildOrderList(pendingOrders),
                ),
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshOrders,
                  child: _buildOrderList(completedOrders),
                ),
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshOrders,
                  child: _buildOrderList(cancelledOrders),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders in this category',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final accentColor = _statusColor(order.status);
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  order.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity: ${order.quantity}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'GH₵ ${order.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${_formatStatus(order.status)}',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ordered: ${DateFormat.yMMMd().format(order.createdAt)}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
