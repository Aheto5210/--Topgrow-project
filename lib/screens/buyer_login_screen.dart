
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';
import 'package:top_grow_project/screens/buyer_signup_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';
import '../provider/auth_provider.dart';

class BuyerSigninScreen extends StatefulWidget {
  static String id = 'buyer_signin_screen'; // Unique ID for navigation.

  const BuyerSigninScreen({super.key});

  @override
  State<BuyerSigninScreen> createState() => _BuyerSigninScreenState();
}

class _BuyerSigninScreenState extends State<BuyerSigninScreen> {
  final TextEditingController _phonenumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phonenumberController.dispose();
    super.dispose();
  }

  // Starts phone verification and shows OTP bottom sheet for sign-in.
  Future<void> _startLogin() async {
    final phoneNumber = _phonenumberController.text.trim();
    final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'buyer';

    // Basic input validation
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please enter a phone number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithPhoneNumber(phoneNumber, context, (
          verificationId,
          ) {
        // Show OTP bottom sheet after verification ID is received
        OtpBottomSheet.show(
          context,
          phoneNumber,
          role: role,
          isSignup: false,
        );
      });
    } catch (e) {
      // Log error for debugging; show user-friendly message
      print('Error in _startLogin: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and text scaling for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect to home screen if user is already signed in
        if (authProvider.user != null && authProvider.role == 'buyer') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, BuyerHomeScreen.id);
          });
        }

        return Scaffold(
          backgroundColor: iykBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                // Responsive padding: 5% of screen width/height, capped
                padding: EdgeInsets.symmetric(
                  horizontal: (screenWidth * 0.05).clamp(16, 32),
                  vertical: (screenHeight * 0.05).clamp(20, 40),
                ),
                child: ConstrainedBox(
                  // Max width for large screens to keep content compact
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          // Responsive logo: 25% of screen height, capped
                          height: (screenHeight * 0.25).clamp(120, 200),
                          width: (screenWidth * 0.5).clamp(150, 300),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Sign in to ',
                          style: TextStyle(
                            fontFamily: 'qwerty',
                            fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                            color: const Color.fromRGBO(59, 135, 81, 1),
                          ),
                          children: [
                            TextSpan(
                              text: 'your Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'qwerty',
                                fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8, 16)), // Responsive spacer
                      Text(
                        'Sign in as a Buyer',
                        style: TextStyle(
                          fontFamily: 'qwerty',
                          fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 20),
                          fontWeight: FontWeight.w400,
                          color: const Color.fromRGBO(121, 121, 121, 1),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.04).clamp(16, 32)),
                      CustomTextfield(
                        hintText: 'Phone Number (e.g., +233123456789)',
                        controller: _phonenumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: (screenHeight * 0.04).clamp(16, 32)),
                      CustomElevatedButton(
                        text: 'Sign in',
                        onPressed: _isLoading ? null : _startLogin,
                        isLoading: _isLoading,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: textScaler.scale(screenWidth * 0.04).clamp(12, 18),
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'buyer';
                              Navigator.pushNamed(
                                context,
                                BuyerSignupScreen.id,
                                arguments: role,
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: textScaler.scale(screenWidth * 0.04).clamp(12, 18),
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(59, 135, 81, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}