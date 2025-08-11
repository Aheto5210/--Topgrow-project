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

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.role == 'farmer') {
              Navigator.pushReplacementNamed(context, FarmerSigninScreen.id);
            } else if (authProvider.role == 'buyer') {
              Navigator.pushReplacementNamed(context, BuyerSigninScreen.id);
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        // Logo
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 16.0),
                        //   child: SizedBox(
                        //     child: Image.asset(
                        //       'assets/images/logo.png',
                        //       height:240,
                        //       fit: BoxFit.contain,
                        //     ),
                        //   ),
                        // ),

                        // Replaced video with image
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/logo.png', // replace with your image path
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),


                        const SizedBox(height: 40),

                        const Text(
                          'Choose A Role',
                          style: TextStyle(
                            color: Color.fromRGBO(59, 135, 81, 1),
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),

                        // const Spacer(),

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
                        const SizedBox(height: 10),
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

                        // const Spacer(),
                      ],
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
