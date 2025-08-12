import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final String _paystackPublicKey = 'pk_test_c4af31d3cb2e8d31e88269225508857335ba30cc';

  Future<bool> _makePayment(double amount, String email, String reference) async {
    try {
      final result = await PayWithPayStack().now(
        context: context,
        secretKey: _paystackPublicKey,
        customerEmail: email,
        reference: reference,
        currency: 'GHS',
        amount: amount * 100,
        callbackUrl: 'https://us-central1-your-project-id.cloudfunctions.net/paymentCallback',
        transactionCompleted: (data) {
          debugPrint("Transaction Completed: ${data.reference}");
        },
        transactionNotCompleted: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: $message')),
          );
          debugPrint("Transaction Not Completed: $message");
        },
      );

      if (result != null && result.status == 'success') {
        debugPrint("Payment Initiated: ${result.reference}");
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment was cancelled or failed')),
        );
        debugPrint("Payment Failed or Cancelled: ${result?.status}");
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
      debugPrint("Payment error: $e");
      return false;
    }
  }

  Future<void> _placeOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to place an order')),
      );
      return;
    }

    if (widget.product.name.isEmpty ||
        widget.product.price <= 0 ||
        widget.product.location.isEmpty ||
        widget.product.farmerId.isEmpty ||
        widget.product.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid product details')),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be at least 1')),
      );
      return;
    }

    try {
      if (_selectedPaymentMethod == 'Pay Now') {
        final totalPrice = widget.product.price * _quantity;
        final reference = 'order_${DateTime.now().millisecondsSinceEpoch}';
        final paymentSuccess = await _makePayment(totalPrice, user.email ?? 'user@example.com', reference);
        if (!paymentSuccess) {
          return;
        }
        await _orderService.createOrder(
          widget.product,
          _quantity,
          // buyerName and buyerContact removed here
        );
      } else {
        await _orderService.createOrder(
          widget.product,
          _quantity,
          // buyerName and buyerContact removed here
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pop(context);
      await Navigator.pushReplacementNamed(context, OrderScreen.id);
    } on firestore.FirebaseException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'Permission denied. Please check Firestore rules.';
          break;
        case 'unavailable':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Failed to place order: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
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
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'Cash on Delivery';
                    });
                  },
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
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'Pay Now';
                    });
                  },
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
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
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
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
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
