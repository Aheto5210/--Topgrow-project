import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Custom exception for authentication-related errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

// Manages authentication state and user data using Firebase
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _fullName;
  String? _role;
  String? _verificationId;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        clearUserData();
      }
    });
  }

  User? get user => _user;
  String? get fullName => _fullName;
  String? get role => _role;

  // Validates phone number format
  String? validatePhoneNumber(String phoneNumber) {
    final RegExp phoneRegex = RegExp(r'^\+\d{9,15}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      return 'Invalid phone number. Use format: +233123456789.';
    }
    return null;
  }

  // Validates full name format
  String? validateFullName(String fullName) {
    final RegExp nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
    if (!nameRegex.hasMatch(fullName)) {
      return 'Full name must be 2-50 letters/spaces.';
    }
    return null;
  }

  // Validates OTP format
  String? validateOtp(String otp) {
    final RegExp otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(otp)) {
      return 'OTP must be 6 digits.';
    }
    return null;
  }

  // Checks network connectivity
  Future<bool> _isConnected() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  // Checks if a phone number exists in Firestore
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        throw AuthException('No internet. Please connect and retry.');
      }
      throw AuthException('Failed to check phone number.');
    }
  }

  // Initiates phone number verification for sign-in
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
    required Function(String) onCodeSent,
  }) async {
    if (!await _isConnected()) {
      throw AuthException('No internet. Please connect and retry.');
    }

    try {
      final phoneExists = await checkPhoneNumberExists(phoneNumber);
      if (!phoneExists) {
        throw AuthException('Phone number not found. Sign up instead.');
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            throw AuthException('Invalid phone number.');
          } else if (e.code == 'too-many-requests') {
            throw AuthException('Too many attempts. Try again later.');
          } else if (e.code == 'network-request-failed') {
            throw AuthException('No internet. Please connect and retry.');
          }
          throw AuthException('Phone verification failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Initiates phone number verification for sign-up
  Future<void> signUpWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
    required Function(String) onCodeSent,
  }) async {
    if (!await _isConnected()) {
      throw AuthException('No internet. Please connect and retry.');
    }

    try {
      final phoneExists = await checkPhoneNumberExists(phoneNumber);
      if (phoneExists) {
        throw AuthException('Phone number already exists. Sign in instead.');
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            throw AuthException('Invalid phone number.');
          } else if (e.code == 'too-many-requests') {
            throw AuthException('Too many attempts. Try again later.');
          } else if (e.code == 'network-request-failed') {
            throw AuthException('No internet. Please connect and retry.');
          }
          throw AuthException('Phone verification failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verifies OTP and signs in the user
  Future<void> verifyOtpAndSignIn({
    required String smsCode,
    required String phoneNumber,
    String? fullName,
    required String role,
    required bool isSignup,
  }) async {
    if (!await _isConnected()) {
      throw AuthException('No internet. Please connect and retry.');
    }

    if (_verificationId == null) {
      throw AuthException('Session expired. Start again.');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);

      if (isSignup) {
        if (fullName == null) {
          throw AuthException('Full name is required.');
        }
        final fullNameError = validateFullName(fullName);
        if (fullNameError != null) {
          throw AuthException(fullNameError);
        }

        await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await _fetchUserData(_auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw AuthException('Invalid OTP. Try again.');
      } else if (e.code == 'session-expired') {
        throw AuthException('OTP expired. Request a new code.');
      } else if (e.code == 'network-request-failed') {
        throw AuthException('No internet. Please connect and retry.');
      }
      throw AuthException('Authentication failed.');
    }
  }

  // Fetches user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _fullName = data['fullName'] as String?;
        _role = data['role'] as String?;
        notifyListeners();
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        throw AuthException('No internet. Please connect and retry.');
      }
      throw AuthException('Failed to fetch user data.');
    }
  }

  // Clears user-related data and notifies listeners
  void clearUserData() {
    _user = null;
    _fullName = null;
    _role = null;
    _verificationId = null;
    notifyListeners();
  }

  // Signs out the user
  Future<void> signOut() async {
    if (!await _isConnected()) {
      throw AuthException('No internet. Please connect and retry.');
    }
    await _auth.signOut();
    clearUserData();
  }
}