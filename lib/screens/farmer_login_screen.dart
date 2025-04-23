import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/screens/farmer_signup_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';
import '../home_bot_nav.dart';
import 'buyer_home_screen.dart';
import '../provider/auth_provider.dart';

class FarmerSigninScreen extends StatefulWidget {
  static String id = 'farmer_signin_screen'; // Unique ID for navigation.

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

  // Starts phone verification and shows OTP bottom sheet.
  Future<void> _startLogin() async {
    final phoneNumber = _phonenumberController.text.trim();
    final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer';

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
      await authProvider.signInWithPhoneNumber(phoneNumber, context, (verificationId) {
        // Show OTP bottom sheet after verification ID is received
        OtpBottomSheet.show(
          context,
          phoneNumber,
          role: role,
          isSignup: false,
        );
        // Stop loader when OTP bottom sheet is shown
        setState(() => _isLoading = false);
      });
    } catch (e) {
      print('Error in _startLogin: $e');
      setState(() => _isLoading = false); // Stop loader on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: ${e.toString()}'),
        ),
      );
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
        // Redirect to dashboard if user is already signed in
        if (authProvider.user != null && authProvider.role == 'farmer') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer';
            Navigator.pushReplacementNamed(
              context,
              role == 'farmer' ? HomeBotnav.id : BuyerHomeScreen.id,
            );
          });
        }

        return Scaffold(
          backgroundColor: iykBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (screenWidth * 0.05).clamp(16, 32),
                  vertical: (screenHeight * 0.05).clamp(20, 40),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Hero(
                          tag: 'logo',
                          child: SizedBox(
                            height: (screenHeight * 0.25).clamp(120, 200),
                            width: (screenWidth * 0.5).clamp(150, 300),
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Sign In To Your',
                          style: TextStyle(
                            fontFamily: 'Qwerty',
                            fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                            color: const Color.fromRGBO(59, 135, 81, 1),
                          ),
                          children: [
                            TextSpan(
                              text: ' Farmer Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Qwerty',
                                fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                      Text(
                        'Login as a Farmer',
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
                      SizedBox(height: (screenHeight * 0.03).clamp(12, 24)),
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
                              final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'farmer';
                              Navigator.pushNamed(
                                context,
                                FarmerSignupScreen.id,
                                arguments: role,
                              );
                            },
                            child: Text(
                              'Sign Up',
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