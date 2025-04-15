import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'package:top_grow_project/screens/buyer_home_screen.dart';

import 'package:top_grow_project/widgets/custom_elevated_button.dart';

import '../home_bot_nav.dart';
import '../provider/auth_provider.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber; // Phone number being verified
  final String? fullName; // Full name for signup
  final String? role; // Role (farmer/buyer) for navigation
  final bool isSignup; // Indicates if this is a signup or login attempt

  const OtpBottomSheet({
    super.key,
    required this.phoneNumber,
    this.fullName,
    this.role,
    this.isSignup = false,
  });

  // Static method to show the bottom sheet
  static void show(
    BuildContext context,
    String phoneNumber, {
    String? fullName,
    String? role,
    bool isSignup = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder:
          (context) => OtpBottomSheet(
            phoneNumber: phoneNumber,
            fullName: fullName,
            role: role,
            isSignup: isSignup,
          ),
    );
  }

  @override
  _OtpBottomSheetState createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  String smsCode = ''; // Stores the entered OTP
  bool _isLoading = false; // Tracks loading state for UI feedback

  // Verifies the OTP using AuthProvider
  Future<void> _verifyCode() async {
    setState(() => _isLoading = true); // Show loading state
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Use the unified verifyOtpAndSignIn method from AuthProvider
      await authProvider.verifyOtpAndSignIn(
        authProvider.verificationId ?? '',
        smsCode,
        widget.isSignup ? (widget.fullName ?? '') : '', // Full name for signup
        widget.role ?? 'farmer', // Default to 'farmer' if role not provided
        context,
      );

      // Close bottom sheet
      Navigator.pop(context);

      // Navigate to the appropriate home screen based on role
      final role = widget.role ?? 'farmer';
      Navigator.pushReplacementNamed(
        context,
        role == 'farmer' ? HomeBotnav.id : BuyerHomeScreen.id,
      );
    } catch (e) {
    } finally {
      setState(() => _isLoading = false); // Reset loading state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, //
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Verify your Phone Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(59, 135, 81, 1),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please enter the 6-digit code we sent to your number',
              style: TextStyle(color: Color(0xFF797979)),
            ),
            const SizedBox(height: 30),
            PinCodeTextField(
              autoFocus: true,
              appContext: context,
              length: 6,
              // 6-digit OTP
              onChanged: (value) => setState(() => smsCode = value),
              // Update smsCode as user types
              onCompleted: (_) => _verifyCode(),
              // Auto-verify when complete
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                inactiveColor: Colors.grey,
                selectedColor: const Color.fromRGBO(59, 135, 81, 1),
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.grey[200],
                selectedFillColor: Colors.white,
              ),
              enableActiveFill: true,
              animationDuration: Duration.zero,
              textStyle: const TextStyle(fontSize: 20),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              text: _isLoading ? 'Verifying...' : 'Verify', // Show loading text
              onPressed:
                  _isLoading
                      ? null
                      : _verifyCode, // Disable button during loading
            ),
          ],
        ),
      ),
    );
  }
}
