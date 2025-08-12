import 'package:flutter/material.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';
import 'package:top_grow_project/screens/buyer_interest_screen.dart';
import 'package:top_grow_project/screens/buyer_profile_screen.dart';
import 'package:top_grow_project/screens/buyer_store_screen.dart';
import 'package:top_grow_project/screens/order_screen.dart';
import 'package:top_grow_project/widgets/buyer_custom_bottombar.dart';

class BuyerBotNav extends StatefulWidget {
  static String id = 'buyer_botnav';
  final int initialIndex;

  const BuyerBotNav({
    super.key,
    this.initialIndex = 0, // default to first tab
  });

  @override
  State<BuyerBotNav> createState() => _BuyerBotNavState();
}

class _BuyerBotNavState extends State<BuyerBotNav> {
  late int _selectedIndex;

  final List<Widget> _widgetOptions = const [
    BuyerHomeScreen(),
    BuyerStoreScreen(),
    OrderScreen(),
    BuyerInterestScreen(),
    BuyerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BuyerCustomBottombar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
