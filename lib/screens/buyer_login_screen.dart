import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:top_grow_project/buyer_bot_nav.dart';
import 'package:top_grow_project/constants.dart';
 import 'package:top_grow_project/screens/buyer_signup_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';
import '../provider/auth_provider.dart';

// Screen for buyer sign-in using phone number
class BuyerSigninScreen extends StatefulWidget {
  static const String id = 'buyer_signin_screen';

  const BuyerSigninScreen({super.key});

  @override
  State<BuyerSigninScreen> createState() => _BuyerSigninScreenState();
}

class _BuyerSigninScreenState extends State<BuyerSigninScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  String? _phoneNumberError;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Initiates the sign-in process with phone number
  Future<void> _startSignIn() async {
    if (_isLoading) return;

    final phoneNumber = _phoneNumberController.text.trim();
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'buyer';

    if (phoneNumber.isEmpty) {
      setState(() => _phoneNumberError = 'Enter a phone number.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneValidationError = authProvider.validatePhoneNumber(phoneNumber);
    if (phoneValidationError != null) {
      setState(() => _phoneNumberError = phoneValidationError);
      return;
    }

    if ((await Connectivity().checkConnectivity()).contains(ConnectivityResult.none)) {
      _showErrorSnackBar('No internet. Please connect and retry.');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneNumberError = null;
    });

    try {
      await authProvider.signInWithPhoneNumber(
        phoneNumber: phoneNumber,
        context: context,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false; // Stop loading when OTP sheet appears
          });
          OtpBottomSheet.show(
            context,
            phoneNumber: phoneNumber,
            role: role,
            isSignup: false,
          );
        },
      );
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      _showErrorSnackBar('Something went wrong. Please retry.');
    }
  }

  // Shows error snackbar with the provided message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _startSignIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user != null && authProvider.role == 'buyer') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, BuyerBotNav.id);
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
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Sign In To ',
                          style: TextStyle(
                            fontFamily: 'Qwerty',
                            fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                            color: const Color.fromRGBO(59, 135, 81, 1),
                          ),
                          children: [
                            TextSpan(
                              text: 'Your Buyer Account',
                              style: TextStyle(
                                fontFamily: 'Qwerty',
                                fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                      Text(
                        'Login as a Buyer',
                        style: TextStyle(
                          fontFamily: 'Qwerty',
                          fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 20),
                          fontWeight: FontWeight.w400,
                          color: const Color.fromRGBO(121, 121, 121, 1),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.04).clamp(16, 32)),
                      CustomTextfield(
                        hintText: 'Phone Number (e.g., +233123456789)',
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        errorText: _phoneNumberError,
                        onChanged: (value) {
                          if (_phoneNumberError != null) {
                            setState(() => _phoneNumberError = null);
                          }
                        },
                      ),
                      SizedBox(height: (screenHeight * 0.03).clamp(12, 24)),
                      CustomElevatedButton(
                        text: _isLoading ? 'Signing In...' : 'Sign In',
                        onPressed: _isLoading ? null : _startSignIn,
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: textScaler.scale(screenWidth * 0.04).clamp(12, 18),
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'buyer';
                              Navigator.pushNamed(
                                context,
                                BuyerSignupScreen.id,
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