import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/provider/auth_provider.dart';
import 'package:top_grow_project/screens/buyer_login_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';

class BuyerSignupScreen extends StatefulWidget {
  static String id = 'buyer_signup_screen'; // Screen identifier for navigation

  const BuyerSignupScreen({super.key});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  final TextEditingController _fullnameController = TextEditingController(); // Controller for full name input
  final TextEditingController _phonenumberController = TextEditingController(); // Controller for phone number input
  bool _isLoading = false; // Tracks loading state for UI feedback

  @override
  void dispose() {
    _fullnameController.dispose();
    _phonenumberController.dispose();
    super.dispose();
  }

  // Initiates signup process by starting phone verification
  Future<void> _startSignup() async {
    final fullName = _fullnameController.text.trim();
    final phoneNumber = _phonenumberController.text.trim();
    final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'buyer'; // Default to 'buyer' if no role provided

    // Validate inputs
    if (fullName.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both full name and phone number')),
      );
      return;
    }

    setState(() => _isLoading = true); // Show loading state
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.startPhoneVerification(phoneNumber, context);

      // Wait for verification process to complete (code sent or failed)
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return authProvider.isVerifying;
      });

      // No need to check _verificationId; AuthProvider handles it internally
      OtpBottomSheet.show(context, phoneNumber, fullName: fullName, role: role, isSignup: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false); // Reset loading state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: iykBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center align children
            children: [
              Center(
                child: SizedBox(
                  height: 200,
                  child: Image.asset('assets/images/logo.png'), // App logo
                ),
              ),
              RichText(
                text: const TextSpan(
                  text: 'Create A New',
                  style: TextStyle(
                    fontFamily: 'qwerty',
                    fontSize: 25,
                    color: Color.fromRGBO(59, 135, 81, 1),
                  ),
                  children: [
                    TextSpan(
                      text: ' Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'qwerty',
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up as a Buyer',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(121, 121, 121, 1),
                ),
              ),
              const SizedBox(height: 30),
              CustomTextfield(
                hintText: 'Enter fullname',
                controller: _fullnameController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              CustomTextfield(
                hintText: 'Phone Number',
                controller: _phonenumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Create Account', // Always pass base text
                onPressed: _isLoading ? null : _startSignup, // Disable button during loading
                isLoading: _isLoading, // Show indicator when loading
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'buyer';
                      Navigator.pushNamed(context, BuyerLoginScreen.id, arguments: role);
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(59, 135, 81, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}