import 'package:flutter/material.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';
import 'package:top_grow_project/screens/buyer_interest_screen.dart';
import 'package:top_grow_project/screens/buyer_profile_screen.dart';
import 'package:top_grow_project/screens/buyer_store_screen.dart';
import 'package:top_grow_project/screens/order_screen.dart';
import 'package:top_grow_project/widgets/buyer_custom_bottombar.dart';

class BuyerBotNav extends StatefulWidget {
  static String id = 'buyer_botnav';
  const BuyerBotNav({super.key});

  @override
  State<BuyerBotNav> createState() => _BuyerBotNavState();
}

class _BuyerBotNavState extends State<BuyerBotNav> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const [
    BuyerHomeScreen(),
    BuyerStoreScreen(),
    OrderScreen(),
    BuyerInterestScreen(),
    BuyerProfileScreen(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BuyerCustomBottombar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
