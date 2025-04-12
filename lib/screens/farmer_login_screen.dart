import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/constants.dart';

import 'package:top_grow_project/screens/farmer_signup_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';

import '../provider/auth_provider.dart';
import 'farmer_home_screen.dart';

class FarmerSigninScreen extends StatefulWidget {
  static String id =
      'farmer_signin_screen'; // Updated identifier for consistency

  const FarmerSigninScreen({super.key});

  @override
  State<FarmerSigninScreen> createState() => _FarmerSigninScreenState();
}

class _FarmerSigninScreenState extends State<FarmerSigninScreen> {
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
        ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer';

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
          isSignup: false, // Explicitly set for login
        );
      });
    } catch (e) {
      // Error handling is already done in AuthProvider, but we can log for debugging
      print('Error in _startLogin: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect to dashboard if user is already signed in
        if (authProvider.user != null && authProvider.role == 'farmer') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, FarmerHomeScreen.id);
          });
        }

        return Scaffold(
          backgroundColor: iykBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 200,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    text: 'Sign In To Your',
                    style: TextStyle(
                      fontFamily: 'Qwerty',
                      fontSize: 25,
                      color: Color.fromRGBO(59, 135, 81, 1),
                    ),
                    children: [
                      TextSpan(
                        text: ' Farmer Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Qwerty',
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Login as a Farmer',
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
                const SizedBox(height: 20),
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
                            'farmer';
                        Navigator.pushNamed(
                          context,
                          FarmerSignupScreen.id,
                          arguments: role,
                        );
                      },
                      child: const Text(
                        'Sign Up',
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
        );
      },
    );
  }
}
