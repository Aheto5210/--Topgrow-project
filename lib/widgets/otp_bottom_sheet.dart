import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:top_grow_project/provider/auth_provider.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';

// Displays a bottom sheet for OTP verification
class OtpBottomSheet {
  static void show(
      BuildContext context, {
        required String phoneNumber,
        String? fullName,
        required String role,
        required bool isSignup,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OtpBottomSheetContent(
        phoneNumber: phoneNumber,
        fullName: fullName,
        role: role,
        isSignup: isSignup,
      ),
    );
  }
}

class OtpBottomSheetContent extends StatefulWidget {
  final String phoneNumber;
  final String? fullName;
  final String role;
  final bool isSignup;

  const OtpBottomSheetContent({
    super.key,
    required this.phoneNumber,
    this.fullName,
    required this.role,
    required this.isSignup,
  });

  @override
  State<OtpBottomSheetContent> createState() => _OtpBottomSheetContentState();
}

class _OtpBottomSheetContentState extends State<OtpBottomSheetContent> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode(); // Added FocusNode for PinCodeTextField
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose(); // Dispose of FocusNode
    super.dispose();
  }

  // Verifies the entered OTP and signs in the user
  Future<void> _verifyCode() async {
    if (_isLoading) return;

    if ((await Connectivity().checkConnectivity()).contains(ConnectivityResult.none)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: const Text('No internet. Please connect and retry.'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _verifyCode,
          ),
        ),
      );
      return;
    }

    final otp = _otpController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final otpError = authProvider.validateOtp(otp);
    if (otpError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(otpError),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await authProvider.verifyOtpAndSignIn(
        smsCode: otp,
        phoneNumber: widget.phoneNumber,
        fullName: widget.fullName,
        role: widget.role,
        isSignup: widget.isSignup,
      );
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.message),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Something went wrong. Please retry.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.of(context).textScaler;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom; // Get keyboard height

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight, // Dynamically adjust padding based on keyboard height
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth * 0.05).clamp(16, 32),
            vertical: (screenWidth * 0.05).clamp(20, 40),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'Qwerty',
                  fontSize: textScaler.scale(screenWidth * 0.06).clamp(20, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: (screenWidth * 0.02).clamp(8, 16)),
              Text(
                'We have sent a 6-digit code to ${widget.phoneNumber}',
                style: TextStyle(
                  fontFamily: 'Qwerty',
                  fontSize: textScaler.scale(screenWidth * 0.04).clamp(14, 18),
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: (screenWidth * 0.04).clamp(16, 32)),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                focusNode: _otpFocusNode, // Assign FocusNode to PinCodeTextField
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: (screenWidth * 0.12).clamp(40, 50),
                  fieldWidth: (screenWidth * 0.12).clamp(40, 50),
                  activeFillColor: const Color.fromRGBO(247, 247, 247, 1),
                  inactiveFillColor: const Color.fromRGBO(247, 247, 247, 1),
                  selectedFillColor: const Color.fromRGBO(247, 247, 247, 1),
                  activeColor: const Color.fromRGBO(59, 135, 81, 1),
                  inactiveColor: Colors.grey,
                  selectedColor: const Color.fromRGBO(59, 135, 81, 1),
                ),
                animationType: AnimationType.fade,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (value) => _verifyCode(),
              ),
              SizedBox(height: (screenWidth * 0.04).clamp(16, 32)),
              CustomElevatedButton(
                text: _isLoading ? 'Verifying...' : 'Verify',
                onPressed: _isLoading ? null : _verifyCode,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}