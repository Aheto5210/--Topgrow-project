import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:top_grow_project/home_bot_nav.dart';

class FarmerOrderscreen extends StatefulWidget {
  const FarmerOrderscreen({super.key});

  static const String id = 'farmer_orderscreen';

  @override
  State<FarmerOrderscreen> createState() => _FarmerOrderscreenState();
}

class _FarmerOrderscreenState extends State<FarmerOrderscreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final String currentFarmerId;

  @override
  void initState() {
    super.initState();
    currentFarmerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  String firestoreStatusFromUI(String uiStatus) {
    switch (uiStatus) {
      case 'pending':
        return 'pending_cod';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return uiStatus;
    }
  }

  String uiStatusFromFirestore(String firestoreStatus) {
    switch (firestoreStatus) {
      case 'pending_cod':
        return 'pending';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return firestoreStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff3B8751),
        centerTitle: true,
        title: const AutoSizeText(
          'Orders',
          style: TextStyle(
            fontFamily: 'qwerty',
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
          maxLines: 1,
          minFontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, HomeBotnav.id);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('pending', Colors.orange),
          _buildOrdersList('completed', Colors.green),
          _buildOrdersList('cancelled', Colors.red),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status, Color statusColor) {
    final queryStatus = firestoreStatusFromUI(status);

    if (currentFarmerId.isEmpty) {
      // No logged in user, show message
      return const Center(child: Text('No farmer logged in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('farmerId', isEqualTo: currentFarmerId)
          .where('status', isEqualTo: queryStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final firestoreStatus = order.get('status') as String? ?? '';
            final dropdownValue = uiStatusFromFirestore(firestoreStatus);

            final buyerId = order.get('buyerId') as String? ?? '';

            final unitPrice = (order.get('price') ?? 0) as num;
            final quantity = (order.get('quantity') ?? 0) as num;
            final totalPrice = unitPrice * quantity;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: statusColor.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.receipt_long,
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(buyerId)
                            .get(),
                        builder: (context, buyerSnapshot) {
                          if (buyerSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading buyer info...');
                          }
                          if (!buyerSnapshot.hasData ||
                              !buyerSnapshot.data!.exists) {
                            return const Text('Buyer info not found');
                          }
                          final buyerData =
                          buyerSnapshot.data!.data() as Map<String, dynamic>?;

                          final buyerName =
                              buyerData?['fullName'] as String? ?? 'Unknown Buyer';
                          final buyerContact =
                              buyerData?['phoneNumber'] as String? ?? '';

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.get('productName') as String? ?? 'Product',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Quantity: $quantity',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: GH₵ ${totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Buyer: $buyerName',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (buyerContact.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Buyer phone number not available'),
                                          ),
                                        );
                                        return;
                                      }
                                      final Uri phoneUri = Uri(
                                        scheme: 'tel',
                                        path: buyerContact,
                                      );
                                      if (await canLaunchUrl(phoneUri)) {
                                        await launchUrl(phoneUri);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Could not launch phone dialer'),
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff3B8751),
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: dropdownValue,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'pending',
                                              child: Text('Pending')),
                                          DropdownMenuItem(
                                              value: 'completed',
                                              child: Text('Completed')),
                                          DropdownMenuItem(
                                              value: 'cancelled',
                                              child: Text('Cancelled')),
                                        ],
                                        onChanged: (newValue) {
                                          if (newValue != null) {
                                            final newFirestoreStatus =
                                            firestoreStatusFromUI(newValue);
                                            updateOrderStatus(order.id, newFirestoreStatus);
                                          }
                                        },
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: statusColor,
                                        ),
                                        dropdownColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
