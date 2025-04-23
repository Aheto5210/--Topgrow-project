import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _fullName;
  String? _role;
  String? _verificationId; // Store verificationId for OTP verification

  User? get user => _user;
  String? get fullName => _fullName;
  String? get role => _role;
  String? get verificationId => _verificationId;

  AuthProvider() {
    // Check current user instead of signing out
    _user = _auth.currentUser;
    if (_user != null) {
      _fetchUserData(_user!.uid);
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _fullName = doc['fullName'] as String?;
        _role = doc['role'] as String?;
        notifyListeners();
      } else {
        await _signOut(); // Clear state if user doc doesn't exist
      }
    } catch (e) {
      await _signOut(); // Clear state on error
      debugPrint('Error fetching user data: $e');
    }
  }

  // Validate full name using regex
  String? validateFullName(String fullName) {
    if (fullName.isEmpty) {
      return 'Full name cannot be empty';
    }
    if (!RegExp(r'^[a-zA-Z\s]{2,50}$').hasMatch(fullName)) {
      return 'Full name must contain only letters and spaces, and be 2-50 characters long';
    }
    return null;
  }

  // Validate phone number using regex
  String? validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (!RegExp(r'^\+\d{9,15}$').hasMatch(phoneNumber)) {
      return 'Phone number must start with "+" followed by 9-15 digits (e.g., +233123456789)';
    }
    return null;
  }

  // Validate OTP using regex
  String? validateOtp(String otp) {
    if (otp.isEmpty) {
      return 'OTP cannot be empty';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must be exactly 6 digits';
    }
    return null;
  }

  // Check if the phone number exists in Firestore
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking phone number: $e');
      return false;
    }
  }

  // Start phone verification (for sign-in/signup and resend OTP)
  Future<void> startPhoneVerification(String phoneNumber, BuildContext context) async {
    try {
      String? phoneError = validatePhoneNumber(phoneNumber);
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text(phoneError)),
        );
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          _user = userCredential.user;
          if (_user != null) {
            await _fetchUserData(_user!.uid);
          }
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(errorMessage),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Error starting verification: $e'),
        ),
      );
    }
  }

  // Sign in with phone number
  Future<void> signInWithPhoneNumber(String phoneNumber, BuildContext context, Function(String) onCodeSent) async {
    try {
      bool phoneExists = await checkPhoneNumberExists(phoneNumber);
      if (!phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Phone number not found. Please sign up first.'),
          ),
        );
        return;
      }
      await startPhoneVerification(phoneNumber, context);
      onCodeSent(_verificationId ?? '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // Sign up with phone number
  Future<void> signUpWithPhoneNumber(String phoneNumber, BuildContext context, Function(String) onCodeSent) async {
    try {
      bool phoneExists = await checkPhoneNumberExists(phoneNumber);
      if (phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Phone number already exists. Please sign in instead.'),
          ),
        );
        return;
      }
      await startPhoneVerification(phoneNumber, context);
      onCodeSent(_verificationId ?? '');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  // Verify OTP and sign in
  Future<void> verifyOtpAndSignIn(String verificationId, String smsCode, String fullName, String role, BuildContext context) async {
    try {
      String? otpError = validateOtp(smsCode);
      if (otpError != null) {
        throw Exception(otpError);
      }

      if (fullName.isNotEmpty) {
        String? nameError = validateFullName(fullName);
        if (nameError != null) {
          throw Exception(nameError);
        }
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      if (_user != null) {
        if (fullName.isNotEmpty) {
          await _firestore.collection('users').doc(_user!.uid).set({
            'fullName': fullName,
            'phoneNumber': _user!.phoneNumber,
            'role': role,
          }, SetOptions(merge: true));
        }
        await _fetchUserData(_user!.uid);
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error verifying OTP. Please try again.';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Incorrect OTP. Please check the code and try again.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'The OTP has expired. Please request a new one.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out (internal)
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _fullName = null;
      _role = null;
      _verificationId = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Public method to clear user data and notify listeners
  void clearUserData() {
    _user = null;
    _fullName = null;
    _role = null;
    _verificationId = null;
    notifyListeners();
  }
}