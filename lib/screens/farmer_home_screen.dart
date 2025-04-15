import 'package:flutter/material.dart';

import '../widgets/custom_appbar.dart';

class FarmerHomeScreen extends StatelessWidget {
  static String id = 'farmer_home_screen';

  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          CustomAppbar(
            hintText: "Search for any product",
            controller: TextEditingController(),
          ),
        ],
      ),
    );
  }
}
