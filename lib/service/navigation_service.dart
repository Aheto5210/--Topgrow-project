import 'package:flutter/material.dart';
import 'package:top_grow_project/buyer_bot_nav.dart';
import 'package:top_grow_project/home_bot_nav.dart';

class NavigationService {
  static void navigateAfterAuth(NavigatorState navigator, String? role) {
    debugPrint('Navigating with role: $role');
    String route = role?.toLowerCase() == 'farmer' ? HomeBotnav.id : BuyerBotNav.id;
    navigator.pushReplacementNamed(route);
  }
}