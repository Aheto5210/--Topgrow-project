import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user; // Current authenticated user
  String? _fullName; // User's full name loaded from Firestore
  String? _verificationId; // Stores verification ID from phone auth
  bool _isVerifying = false; // Tracks if verification is in progress

  // Constructor: Listens to auth state changes and loads user data
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData(user.uid).catchError((e) {
          // Error handling for loading user data
        });
      }
      notifyListeners();1
    });
  }

  // Getters for accessing private fields
  User? get user => _user;
  String? get fullName => _fullName;
  bool get isAuthenticated => _user != null;
  bool get isVerifying => _isVerifying;

  // Starts phone number verification process
  Future<void> startPhoneVerification(String phoneNumber, BuildContext context) async {
    try {
      if (phoneNumber.isEmpty) {
        throw Exception('Phone number cannot be empty');
      }
      _isVerifying = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } on FirebaseAuthException catch (e) {
            _handleAuthError(e, context);
          }
          _isVerifying = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _handleAuthError(e, context);
          _isVerifying = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isVerifying = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          _isVerifying = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _handleGenericError(e, context);
      _isVerifying = false;
      notifyListeners();
    }
  }

  // Verifies OTP for signup, only allows new users
  Future<void> verifySignupCode(String smsCode, String fullName, String role, BuildContext context) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification in progress. Please start verification first.');
      }
      if (smsCode.isEmpty) {
        throw Exception('SMS code cannot be empty');
      }
      if (fullName.isEmpty || role.isEmpty) {
        throw Exception('Full name and role are required for signup.');
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      // Only new users can sign up
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _saveUserData(userCredential.user!.uid, fullName, role);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Welcome aboard.')),
        );
      } else {
        await _auth.signOut(); // Prevent login state
        throw Exception('This phone number is already registered. Please sign in instead.');
      }
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow; // Allow UI to handle navigation
    }
  }

  // Verifies OTP for login, only allows existing users
  Future<void> verifyLoginCode(String smsCode, BuildContext context) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification in progress. Please start verification first.');
      }
      if (smsCode.isEmpty) {
        throw Exception('SMS code cannot be empty');
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      // Only existing users can log in
      if (!userCredential.additionalUserInfo!.isNewUser) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor:  Color.fromRGBO(59, 135, 81, 1),
              content: Text('Login successful! Welcome back.')),
        );
      } else {
        await _auth.signOut(); // Prevent login state
        throw Exception('No account found. Please sign up first.');
      }
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
             backgroundColor:Colors.red,
            content: Text(e.toString())),
      );
      rethrow; // Allow UI to handle navigation
    }
  }

  // Saves user data to Firestore during signup
  Future<void> _saveUserData(String uid, String fullName, String role) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'phoneNumber': _user!.phoneNumber,
        'role': role,
      });
      _fullName = fullName;
      notifyListeners();
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  // Loads user data from Firestore on auth state change
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _fullName = doc['fullName'];
        notifyListeners();
      }
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  // Signs out the user and clears local data
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _fullName = null;
      _verificationId = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Displays Firebase Auth errors to the user
  void _handleAuthError(FirebaseAuthException e, BuildContext context) {
    String message;
    switch (e.code) {
      case 'invalid-phone-number':
        message = 'The phone number format is invalid. Please use +[country code][number].';
        break;
      case 'invalid-verification-code':
        message = 'The SMS code is incorrect. Please try again.';
        break;
      case 'quota-exceeded':
        message = 'SMS quota exceeded. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      default:
        message = e.message ?? 'Authentication failed. Please try again.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         backgroundColor:Colors.red,
        content: Text(message)));
  }

  // Maps Firebase Auth errors to exceptions
  Exception _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return Exception('Incorrect SMS code. Please try again.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please wait before trying again.');
      default:
        return Exception('Authentication error: ${e.message ?? e.code}');
    }
  }

  // Maps Firestore errors to exceptions
  Exception _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Permission denied. Cannot access user data.');
      case 'unavailable':
        return Exception('Firestore is unavailable. Please check your connection.');
      case 'not-found':
        return Exception('User data not found.');
      default:
        return Exception('Firestore error: ${e.message ?? e.code}');
    }
  }

  // Displays generic errors to the user
  void _handleGenericError(dynamic e, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor:Colors.red,
          content: Text(e.toString())),
    );
  }
}