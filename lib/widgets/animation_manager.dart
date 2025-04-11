import 'package:flutter/material.dart';

// Class to manage animations for the WelcomeScreen
class WelcomeScreenAnimationManager {
  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideFromRightAnimation;
  late Animation<Offset> slideFromLeftAnimation;
  late Animation<double> scaleAnimation;

  WelcomeScreenAnimationManager(TickerProvider vsync) {
    // Initialize the animation controller
    controller = AnimationController(
      duration: const Duration(seconds: 2), // Total duration of the animation
      vsync: vsync,
    );

    // Fade animation (0.0 to 1.0 for opacity)
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Slide from right animation for Timg.png
    slideFromRightAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start off-screen to the right
      end: Offset.zero, // End at the original position
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Slide from left animation for hand.png
    slideFromLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen to the left
      end: Offset.zero, // End at the original position
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Scale animation for the logo
    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Start the animation
    controller.forward();
  }

  // Dispose of the animation controller to free resources
  void dispose() {
    controller.dispose();
  }
}