import 'package:flutter/material.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/screens/buyer_login_screen.dart';
import 'package:top_grow_project/screens/farmer_login_screen.dart';
import 'package:top_grow_project/widgets/custom_elevated_button.dart';

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
      setState(() {
        _opacity = 1.0;
        _skipButtonPosition = 20;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: iykBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Choose A Role',
                  style: TextStyle(
                    color: const Color.fromRGBO(59, 135, 81, 1),
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            Center(
              child: AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: _opacity,
                child: Column(
                  children: [
                    const Spacer(flex: 5),
                    CustomElevatedButton(
                      text: 'Farmer',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          FarmerLoginScreen.id,
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
                          BuyerLoginScreen.id,
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
  }
}