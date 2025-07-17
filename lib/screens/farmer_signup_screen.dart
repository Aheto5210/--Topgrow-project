import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';
import 'package:top_grow_project/widgets/custom_textfield.dart';
import 'package:top_grow_project/widgets/otp_bottom_sheet.dart';
import '../home_bot_nav.dart';
import '../provider/auth_provider.dart';
import 'farmer_login_screen.dart';

// Screen for farmer sign-up with full name and phone number
class FarmerSignupScreen extends StatefulWidget {
  static const String id = 'farmer_signup_screen';

  const FarmerSignupScreen({super.key});

  @override
  State<FarmerSignupScreen> createState() => _FarmerSignupScreenState();
}

class _FarmerSignupScreenState extends State<FarmerSignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  String? _fullNameError;
  String? _phoneNumberError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Initiates the sign-up process with phone number and full name
  Future<void> _startSignUp() async {
    if (_isLoading) return;

    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final role =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'farmer';

    setState(() {
      _fullNameError = fullName.isEmpty ? 'Enter your full name.' : null;
      _phoneNumberError = phoneNumber.isEmpty ? 'Enter a phone number.' : null;
    });

    if (_fullNameError != null || _phoneNumberError != null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fullNameError = authProvider.validateFullName(fullName);
    final phoneError = authProvider.validatePhoneNumber(phoneNumber);
    setState(() {
      _fullNameError = fullNameError;
      _phoneNumberError = phoneError;
    });

    if (_fullNameError != null || _phoneNumberError != null) return;

    if ((await Connectivity().checkConnectivity()).contains(
      ConnectivityResult.none,
    )) {
      _showErrorSnackBar('No internet. Please connect and retry.');
      return;
    }

    setState(() {
      _isLoading = true;
      _fullNameError = null;
      _phoneNumberError = null;
    });

    try {
      await authProvider.signUpWithPhoneNumber(
        phoneNumber: phoneNumber,
        context: context,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false; // Stop loading when OTP sheet appears
          });
          OtpBottomSheet.show(
            context,
            phoneNumber: phoneNumber,
            fullName: fullName,
            role: role,
            isSignup: true,
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
        action: SnackBarAction(label: 'Retry', onPressed: _startSignUp),
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
        if (authProvider.user != null && authProvider.role != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final role = authProvider.role!;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 30,
                        child: IconButton(
                          onPressed: () {Navigator.pushNamed(context, FarmerSigninScreen.id);},
                          icon: Icon(Icons.arrow_back, size: 25,
                        ),
                      ),
                      ),
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
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Create A New',
                            style: TextStyle(
                              fontFamily: 'Qwerty',
                              fontSize: textScaler
                                  .scale(screenWidth * 0.04)
                                  .clamp(20, 28),
                              color: const Color.fromRGBO(59, 135, 81, 1),
                            ),
                            children: [
                              TextSpan(
                                text: ' Farmer Account',
                                style: TextStyle(
                                  fontFamily: 'Qwerty',
                                  fontSize: textScaler
                                      .scale(screenWidth * 0.04)
                                      .clamp(20, 28),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                      Center(
                        child: Text(
                          'Sign Up as a Farmer',
                          style: TextStyle(
                            fontFamily: 'Qwerty',
                            fontSize: textScaler
                                .scale(screenWidth * 0.045)
                                .clamp(14, 20),
                            fontWeight: FontWeight.w400,
                            color: const Color.fromRGBO(121, 121, 121, 1),
                          ),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.04).clamp(16, 32)),
                      CustomTextfield(
                        hintText: 'Full Name',
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        enabled: !_isLoading,
                        errorText: _fullNameError,
                        onChanged: (value) {
                          if (_fullNameError != null) {
                            setState(() => _fullNameError = null);
                          }
                        },
                      ),
                      SizedBox(height: (screenHeight * 0.03).clamp(12, 24)),
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
                        text:
                            _isLoading
                                ? 'Creating Account...'
                                : 'Create Account',
                        onPressed: _isLoading ? null : _startSignUp,
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: textScaler
                                  .scale(screenWidth * 0.04)
                                  .clamp(12, 18),
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      final role =
                                          ModalRoute.of(
                                                context,
                                              )?.settings.arguments
                                              as String? ??
                                          'farmer';
                                      Navigator.pushNamed(
                                        context,
                                        FarmerSigninScreen.id,
                                        arguments: role,
                                      );
                                    },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: textScaler
                                    .scale(screenWidth * 0.04)
                                    .clamp(12, 18),
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
