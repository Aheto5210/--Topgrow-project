import 'package:flutter/material.dart';
import 'package:top_grow_project/screens/farmer_home_screen.dart';
import 'package:top_grow_project/screens/product_screen.dart';
import 'package:top_grow_project/screens/profile_screen.dart';
import 'package:top_grow_project/screens/views_screen.dart';
import 'package:top_grow_project/widgets/custom_bottom_bar_nav.dart';

class HomeBotnav extends StatefulWidget {
  static String id = 'home_botnav';
  const HomeBotnav({super.key});

  @override
  State<HomeBotnav> createState() => _HomeBotnavState();
}

class _HomeBotnavState extends State<HomeBotnav> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const [
    FarmerHomeScreen(),
    ProductScreen(),
    ViewsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _widgetOptions.elementAt(_selectedIndex), // Display the selected screen
      bottomNavigationBar: CustomBottomBarNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}