import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';

import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';

import '../provider/auth_provider.dart';
import 'buyer_login_screen.dart';

class BuyerSignupScreen extends StatefulWidget {
  static String id = 'buyer_signup_screen';

  const BuyerSignupScreen({super.key});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  bool _isLoading = false;

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
    final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'buyer';

    // Basic input validation
    if (fullName.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both full name and phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signUpWithPhoneNumber(
        phoneNumber,
        context,
            (verificationId) {
          // Show OTP bottom sheet after verification ID is received
          OtpBottomSheet.show(
            context,
            phoneNumber,
            fullName: fullName,
            role: role,
            isSignup: true,
          );
        },
      );
    } catch (e) {
      // Error handling is already done in AuthProvider, but we can log for debugging
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
                    hintText: 'Phone Number (e.g., +233123456789)',
                    controller: _phonenumberController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    text: 'Create Account',
                    onPressed: _isLoading ? null : _startSignup,
                    isLoading: _isLoading,
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
                          Navigator.pushNamed(context, BuyerSigninScreen.id, arguments: role);
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
      },
    );
  }
}