import 'package:flutter/material.dart';

import '../widgets/custom_appbar.dart';

class FarmerHomeScreen extends StatefulWidget {
  static String id = 'farmer_home_screen';

  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final TextEditingController _searchcontroller = TextEditingController();

  @override
  void dispose() {
    _searchcontroller.dispose();
    super.dispose();
  }

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
