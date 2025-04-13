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
  static String id =
      'buyer_signin_screen'; // Updated identifier for consistency

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

  // Initiates login process by starting phone verification
  Future<void> _startLogin() async {
    final phoneNumber = _phonenumberController.text.trim();
    final role =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'buyer';

    // Basic input validation
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
           backgroundColor: Colors.red,
            content: Text('Please enter a phone number')),

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
          isSignup: false, // Explicitly set for login
        );
      });
    } catch (e) {

    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect to dashboard if user is already signed in
        if (authProvider.user != null && authProvider.role == 'buyer') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, BuyerHomeScreen.id);
          });
        }

        return Scaffold(
          backgroundColor: iykBackgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      text: 'Sign in to ',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: 25,
                        color: Color.fromRGBO(59, 135, 81, 1),
                      ),
                      children: [
                        TextSpan(
                          text: 'your Account',
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
                    'Sign in as a Buyer',
                    style: TextStyle(
                      fontFamily: 'qwerty',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(121, 121, 121, 1),
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextfield(
                    hintText: 'Phone Number (e.g., +233123456789)',
                    controller: _phonenumberController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),
                  CustomElevatedButton(
                    text: 'Sign in',
                    onPressed: _isLoading ? null : _startLogin,
                    isLoading: _isLoading,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          final role =
                              ModalRoute.of(context)!.settings.arguments
                                  as String? ??
                              'buyer';
                          Navigator.pushNamed(
                            context,
                            BuyerSignupScreen.id,
                            arguments: role,
                          );
                        },
                        child: const Text(
                          'Sign up',
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
      },
    );
  }
}
