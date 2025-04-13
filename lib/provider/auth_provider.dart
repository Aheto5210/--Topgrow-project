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
    // On initialization, sign out to clear any persisted session
    _signOutOnInit();
  }

  // Sign out on initialization to prevent auto sign-in
  Future<void> _signOutOnInit() async {
    try {
      await _auth.signOut();
      _user = null;
      _fullName = null;
      _role = null;
      _verificationId = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out on init: $e');
    }
  }

  // Fetch user data from Firestore after manual sign-in
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _fullName = doc['fullName'] as String?;
        _role = doc['role'] as String?;
        notifyListeners();
      } else {
        // If the document doesn't exist, sign the user out to prevent inconsistent state
        await _auth.signOut();
        _user = null;
        _fullName = null;
        _role = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Sign the user out to prevent inconsistent state
      await _auth.signOut();
      _user = null;
      _fullName = null;
      _role = null;
      notifyListeners();
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
      print('Error checking phone number: $e');
      return false;
    }
  }

  // Sign in with phone number (for login)
  Future<void> signInWithPhoneNumber(
      String phoneNumber,
      BuildContext context,
      Function(String) onCodeSent,
      ) async {
    try {
      String? phoneError = validatePhoneNumber(phoneNumber);
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(phoneError)),
        );
        return;
      }

      bool phoneExists = await checkPhoneNumberExists(phoneNumber);
      if (!phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Phone number not found. Please sign up first.'),
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Verification failed: ${e.message}'),
            ),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  // Sign up with phone number (for signup)
  Future<void> signUpWithPhoneNumber(
      String phoneNumber,
      BuildContext context,
      Function(String) onCodeSent,
      ) async {
    try {
      String? phoneError = validatePhoneNumber(phoneNumber);
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(phoneError)),
        );
        return;
      }

      bool phoneExists = await checkPhoneNumberExists(phoneNumber);
      if (phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Phone number already exists. Please sign in instead.'),
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Verification failed: ${e.message}'),
            ),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  // Verify OTP and sign in
  Future<void> verifyOtpAndSignIn(
      String verificationId,
      String smsCode,
      String fullName,
      String role,
      BuildContext context,
      ) async {
    try {
      String? otpError = validateOtp(smsCode);
      if (otpError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(otpError)),
        );
        return;
      }

      if (fullName.isNotEmpty) {
        String? nameError = validateFullName(fullName);
        if (nameError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(nameError)),
          );
          return;
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error verifying OTP: $e'),
        ),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _fullName = null;
      _role = null;
      _verificationId = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}