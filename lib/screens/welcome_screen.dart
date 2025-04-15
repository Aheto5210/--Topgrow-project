import 'package:flutter/material.dart';
import 'package:top_grow_project/screens/role_selection.dart';

import '../widgets/animation_manager.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  // Animation manager to handle all animations
  late WelcomeScreenAnimationManager _animationManager;

  @override
  void initState() {
    super.initState();
    // Initialize the animation manager
    _animationManager = WelcomeScreenAnimationManager(this);
  }

  @override
  void dispose() {
    // Dispose of the animation manager
    _animationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          // Top-right image with slide-in animation
          SlideTransition(
            position: _animationManager.slideFromRightAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 130,
                  child: Image.asset('assets/images/Timg.png'),
                ),
              ],
            ),
          ),

          // Logo with fade-in and scale animation
          FadeTransition(
            opacity: _animationManager.fadeAnimation,
            child: ScaleTransition(
              scale: _animationManager.scaleAnimation,
              child: SizedBox(
                height: 290,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),

          // Bottom-left image with slide-in animation
          SlideTransition(
            position: _animationManager.slideFromLeftAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 190,
                  child: Image.asset('assets/images/hand.png'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Welcome text with fade-in animation
          FadeTransition(
            opacity: _animationManager.fadeAnimation,
            child: Text(
              'Welcome to',
              style: TextStyle(
                fontFamily: 'qwerty',
                fontWeight: FontWeight.w400,
                fontSize: 21,
              ),
            ),
          ),

          // Text with fade-in animation
          FadeTransition(
            opacity: _animationManager.fadeAnimation,
            child: Text(
              'TopGrow Ghana',
              style: TextStyle(
                fontFamily: 'ytrewq',
                fontWeight: FontWeight.w700,
                fontSize: 23,
                color: const Color.fromRGBO(49, 109, 72, 1),
              ),
            ),
          ),

          // Text with fade-in animation
          FadeTransition(
            opacity: _animationManager.fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                'Digital marketplace that empowers farmers to showcase their produce directly to buyers.',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: const Color.fromRGBO(121, 121, 121, 1),
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ),

          // Welcome button with fade-in animation
          FadeTransition(
            opacity: _animationManager.fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(59, 135, 81, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, RoleSelection.id);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}