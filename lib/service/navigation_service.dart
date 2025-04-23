import 'package:flutter/material.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';
import 'package:top_grow_project/home_bot_nav.dart';

class NavigationService {
  static void navigateAfterAuth(BuildContext context, String role) {
    final route = role == 'farmer' ? HomeBotnav.id : BuyerHomeScreen.id;
    Navigator.pushReplacementNamed(context, route);
  }
}