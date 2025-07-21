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
  late WelcomeScreenAnimationManager _animationManager;

  @override
  void initState() {
    super.initState();
    _animationManager = WelcomeScreenAnimationManager(this);
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top-right image pinned to the edge
              SlideTransition(
                position: _animationManager.slideFromRightAnimation,
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: (screenWidth * 0.4).clamp(100, 200),
                    child: Image.asset(
                      'assets/images/Timg.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                ),
              ),

              // Logo
              FadeTransition(
                opacity: _animationManager.fadeAnimation,
                child: ScaleTransition(
                  scale: _animationManager.scaleAnimation,
                  child: SizedBox(
                    height: (screenHeight * 0.25).clamp(120, 200),
                    width: (screenWidth * 0.6).clamp(150, 300),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                ),
              ),

              // Bottom-left image
              SlideTransition(
                position: _animationManager.slideFromLeftAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: (screenHeight * 0.2).clamp(100, 180),
                      width: (screenWidth * 0.6).clamp(120, 250),
                      child: Image.asset(
                        'assets/images/hand2.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Welcome text
              FadeTransition(
                opacity: _animationManager.fadeAnimation,
                child: Text(
                  'Welcome to',
                  style: TextStyle(
                    fontFamily: 'qwerty',
                    fontWeight: FontWeight.w400,
                    fontSize: textScaler.scale(screenWidth * 0.05).clamp(14, 24),
                  ),
                ),
              ),

              // TopGrow Ghana text
              FadeTransition(
                opacity: _animationManager.fadeAnimation,
                child: Text(
                  'TopGrow Ghana',
                  style: TextStyle(
                    fontFamily: 'ytrewq',
                    fontWeight: FontWeight.w700,
                    fontSize: textScaler.scale(screenWidth * 0.06).clamp(16, 28),
                    color: const Color.fromRGBO(49, 109, 72, 1),
                  ),
                ),
              ),

              // Description text
              FadeTransition(
                opacity: _animationManager.fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth * 0.1).clamp(16, 40),
                    vertical: screenHeight * 0.02,
                  ),
                  child: Text(
                    'Digital marketplace that empowers farmers to showcase their produce directly to buyers.',
                    style: TextStyle(
                      fontFamily: 'qwerty',
                      fontWeight: FontWeight.w400,
                      fontSize: textScaler.scale(screenWidth * 0.04).clamp(12, 20),
                      color: const Color.fromRGBO(121, 121, 121, 1),
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),

              // Welcome button
              FadeTransition(
                opacity: _animationManager.fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth * 0.08).clamp(12, 32),
                    vertical: screenHeight * 0.03,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(59, 135, 81, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.05,
                      ),
                      minimumSize: Size(screenWidth * 0.8, screenHeight * 0.07),
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
                            fontSize: textScaler.scale(screenWidth * 0.05).clamp(14, 24),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
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
        ),
      ),
    );
  }
}