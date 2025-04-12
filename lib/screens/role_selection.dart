import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/constants.dart';

import 'package:top_grow_project/widgets/custom_elevated_button.dart';

import '../provider/auth_provider.dart';
import 'buyer_login_screen.dart';
import 'farmer_login_screen.dart';

class RoleSelection extends StatefulWidget {
  static String id = 'role_selection';

  const RoleSelection({super.key});

  @override
  State<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {
  double _opacity = 0.0;
  double _skipButtonPosition = -50;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) { // Ensure the widget is still mounted before calling setState
        setState(() {
          _opacity = 1.0;
          _skipButtonPosition = 20;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect to the appropriate dashboard if user is already signed in
        if (authProvider.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.role == 'farmer') {
              Navigator.pushReplacementNamed(context, 'farmer_dashboard');
            } else if (authProvider.role == 'buyer') {
              Navigator.pushReplacementNamed(context, 'buyer_dashboard');
            }
          });
        }

        return Scaffold(
          backgroundColor: iykBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _opacity,
                    child: Column(
                      children: [
                        const SizedBox(height: 60), // Moved from Row to Column
                        const Text(
                          'Choose A Role',
                          style: TextStyle(
                            color: Color.fromRGBO(59, 135, 81, 1),
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),
                        const Spacer(flex: 5),
                        CustomElevatedButton(
                          text: 'Farmer',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              FarmerSigninScreen.id,
                              arguments: 'farmer',
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                          text: 'Buyer',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              BuyerSigninScreen.id,
                              arguments: 'buyer',
                            );
                          },
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  bottom: _skipButtonPosition,
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Back to WelcomeScreen
                    },
                    child: const Text(
                      'Skip >',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Color.fromRGBO(63, 61, 86, 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}