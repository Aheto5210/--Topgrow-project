import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/provider/auth_provider.dart';
import 'package:top_grow_project/screens/farmer_signup_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';
import '../constants.dart';

class FarmerLoginScreen extends StatefulWidget {
  static String id = 'farmer_login_screen'; // Screen identifier for navigation

  const FarmerLoginScreen({super.key});

  @override
  State<FarmerLoginScreen> createState() => _FarmerLoginScreenState();
}

class _FarmerLoginScreenState extends State<FarmerLoginScreen> {
  final TextEditingController _phonenumberController = TextEditingController(); // Controller for phone number input
  bool _isLoading = false; // Tracks loading state for UI feedback

  @override
  void dispose() {
    _phonenumberController.dispose();
    super.dispose();
  }

  // Initiates login process by starting phone verification
  Future<void> _startLogin() async {
    final phoneNumber = _phonenumberController.text.trim();
    final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer'; // Default to 'farmer' if no role provided

    // Validate input
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
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
      OtpBottomSheet.show(context, phoneNumber, role: role);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200,
                    child: Image.asset('assets/images/logo.png'), // App logo
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
                hintText: 'Enter Mobile Number',
                controller: _phonenumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Sign in', // Always pass base text
                onPressed: _isLoading ? null : _startLogin, // Disable button during loading
                isLoading: _isLoading, // Show indicator when loading
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
                      final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer';
                      Navigator.pushNamed(context, FarmerSignupScreen.id, arguments: role);
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
      ),
    );
  }
}