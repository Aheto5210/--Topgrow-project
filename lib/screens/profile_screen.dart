import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/screens/about_topgrow_screen.dart';
import 'package:top_grow_project/screens/contact_top_screen.dart';
import 'package:top_grow_project/screens/role_selection.dart';
import '../constants.dart';
import '../provider/auth_provider.dart' as CustomAuthProvider;

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoleSelection.id,
                (route) => false,
          );
        });
      }
    });
    _fetchUserData();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in. Please sign in.';
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['fullName'] ?? user.email ?? user.uid;
          _phoneController.text = data['phoneNumber'] ?? '';
        });
      } else {
        setState(() {
          _nameController.text = user.email ?? user.uid;
          _phoneController.text = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please sign in.'), backgroundColor: Colors.red),
      );
      return;
    }

    final name = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': name,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.'), backgroundColor: primaryGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      final authProvider = Provider.of<CustomAuthProvider.AuthProvider>(context, listen: false);
      authProvider.clearUserData();
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.'), backgroundColor: primaryGreen),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, RoleSelection.id, (route) => false);
      }
    } catch (e) {
      String errorMessage = 'Failed to delete account: $e';
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        errorMessage = 'Session expired. Please log in again to delete your account.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await Provider.of<CustomAuthProvider.AuthProvider>(context, listen: false).signOut();
      Navigator.pushNamedAndRemoveUntil(context, RoleSelection.id, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: size.height * 0.20,
              color: const Color(0xffF8FFFB),
              child: Center(
                child: Text(
                  'User Profile',
                  style: TextStyle(
                    fontFamily: 'qwerty',
                    fontWeight: FontWeight.w600,
                    fontSize: textScaler.scale(size.width * 0.05).clamp(18, 20),
                    color: primaryGreen,
                  ),
                ),
              ),
            ),
            _isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(color: primaryGreen),
              ),
            )
                : _errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontFamily: 'qwerty',
                    fontSize: textScaler.scale(size.width * 0.04).clamp(12, 14),
                    color: Colors.red,
                  ),
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: size.width * 0.7,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffFFFFFF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(size.width * 0.035).clamp(10, 12),
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: size.width * 0.7,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffFFFFFF)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(size.width * 0.035).clamp(10, 12),
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUpdating
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text(
                        'Update Details',
                        style: TextStyle(
                          fontFamily: 'qwerty',
                          fontSize: textScaler.scale(size.width * 0.04).clamp(12, 14),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryGreen),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 30,
                        height: 30,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.info, color: primaryGreen, size: 24),
                      ),
                    ),
                    title: Text(
                      'About TopGrow',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(size.width * 0.04).clamp(14, 16),
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pushNamed(context, AboutTopgrowScreen.id);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Contact TopGrow',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(size.width * 0.04).clamp(14, 16),
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pushNamed(context, ContactTopScreen.id);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xffDA4240),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffDA4240)),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(size.width * 0.04).clamp(14, 16),
                        color: Colors.black,
                      ),
                    ),
                    trailing: _isDeleting
                        ? const CircularProgressIndicator(color: Colors.red, strokeWidth: 2)
                        : const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _isDeleting
                        ? null
                        : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deleteAccount();
                      }
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff797979),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler.scale(size.width * 0.04).clamp(14, 16),
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _logout();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension AuthProviderExtension on CustomAuthProvider.AuthProvider {
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      clearUserData();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}