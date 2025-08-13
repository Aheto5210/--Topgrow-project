import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:top_grow_project/models/product.dart';
import 'package:top_grow_project/screens/order_screen.dart';
import 'package:top_grow_project/service/order_service.dart';

class BuyProductDialog extends StatefulWidget {
  final Product product;

  const BuyProductDialog({super.key, required this.product});

  @override
  _BuyProductDialogState createState() => _BuyProductDialogState();
}

class _BuyProductDialogState extends State<BuyProductDialog> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  int _quantity = 1;
  final OrderService _orderService = OrderService();

  /// Public key for client-side payments (Test mode here)
  final String _paystackPublicKey = 'pk_test_c4af31d3cb2e8d31e88269225508857335ba30cc';

  /// Secret key for server-side verification (Test mode here)
  final String _paystackSecretKey = 'sk_test_db6d7259654c7c1f5838f8b4e47ea5fcf43003b5';

  Future<bool> _makePayment(double amount, String phoneNumber, String reference) async {
    final Completer<bool> completer = Completer<bool>();

    try {
      if (amount <= 0) {
        _showSnackBar('Invalid payment amount');
        return false;
      }
      if (phoneNumber.isEmpty || !RegExp(r'^\+?\d{10,15}$').hasMatch(phoneNumber)) {
        _showSnackBar('Invalid phone number');
        return false;
      }

      final customerEmail = '${phoneNumber.replaceAll('+', '')}@yourapp.com';

      PayWithPayStack().now(
        context: context,
        secretKey: _paystackSecretKey,
        customerEmail: customerEmail,
        reference: reference,
        currency: 'GHS',
        amount: (amount * 1),
        callbackUrl: 'https://us-central1-your-project-id.cloudfunctions.net/paymentCallback',
        transactionCompleted: (data) async {
          debugPrint("Transaction Completed: ${data.reference}");
          final verified = await _verifyPayment(reference);
          if (verified) {
            debugPrint("Payment Verified: $reference");
            if (!completer.isCompleted) completer.complete(true);
          } else {
            _showSnackBar('Payment verification failed');
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        transactionNotCompleted: (message) {
          debugPrint("Transaction Not Completed: $message");
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      // Wait here until completer completes from callbacks
      return completer.future;
    } catch (e, st) {
      debugPrint("Payment error: $e\n$st");
      _showSnackBar('Payment error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> _verifyPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_paystackSecretKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint("Verification HTTP error: ${response.statusCode}");
        return false;
      }

      final data = jsonDecode(response.body);
      return data['status'] == true && data['data']['status'] == 'success';
    } catch (e, st) {
      debugPrint("Verification error: $e\n$st");
      return false;
    }
  }

  Future<void> _placeOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.phoneNumber == null) {
      _showSnackBar('Please sign in with a phone number to place an order');
      return;
    }

    if (widget.product.name.isEmpty ||
        widget.product.price <= 0 ||
        widget.product.location.isEmpty ||
        widget.product.farmerId.isEmpty ||
        widget.product.id.isEmpty) {
      _showSnackBar('Invalid product details');
      return;
    }

    if (_quantity <= 0) {
      _showSnackBar('Quantity must be at least 1');
      return;
    }

    _showLoadingDialog();

    try {
      if (_selectedPaymentMethod == 'Pay Now') {
        final totalPrice = widget.product.price * _quantity;
        final reference = 'order_${DateTime.now().millisecondsSinceEpoch}';

        final paymentSuccess = await _makePayment(totalPrice, user.phoneNumber!, reference);

        if (!paymentSuccess) {
          Navigator.of(context, rootNavigator: true).pop();
          return;
        }

        _orderService.setPaymentDetails(_selectedPaymentMethod, reference);
      } else {
        _orderService.setPaymentDetails(_selectedPaymentMethod, null);
      }

      await _orderService.createOrder(widget.product, _quantity);

      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      _showSnackBar('Order placed successfully!');

      Navigator.pop(context); // Close the BuyProductDialog

      // Navigate to OrderScreen straight after order creation
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderScreen()),
      );
    } on firestore.FirebaseException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      String errorMessage;
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'Permission denied. Please check Firestore rules.';
          break;
        case 'unavailable':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Failed to place order: ${e.message ?? e.code}';
      }
      _showSnackBar(errorMessage);
    } catch (e, st) {
      Navigator.of(context, rootNavigator: true).pop();
      debugPrint("Unexpected error placing order: $e\n$st");
      _showSnackBar('Unexpected error occurred. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.product.price * _quantity;
    final textScaler = MediaQuery.of(context).textScaler;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Payment',
            style: TextStyle(
              fontFamily: 'qwerty',
              fontSize: textScaler.scale(screenWidth * 0.06).clamp(18, 24),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPaymentMethod = 'Cash on Delivery'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedPaymentMethod == 'Cash on Delivery'
                          ? const Color(0xff3B8751)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cash on Delivery',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 16),
                        color: _selectedPaymentMethod == 'Cash on Delivery'
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPaymentMethod = 'Pay Now'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedPaymentMethod == 'Pay Now'
                          ? const Color(0xff3B8751)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pay Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 16),
                        color: _selectedPaymentMethod == 'Pay Now'
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity:',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    icon: const Icon(Icons.remove, color: Color(0xff3B8751)),
                  ),
                  Text(
                    '$_quantity',
                    style: TextStyle(
                      fontFamily: 'qwerty',
                      fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 16),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add, color: Color(0xff3B8751)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Price: GH₵ ${totalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: 'qwerty',
              fontSize: textScaler.scale(screenWidth * 0.05).clamp(16, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xff3B8751),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _placeOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3B8751),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 16),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
