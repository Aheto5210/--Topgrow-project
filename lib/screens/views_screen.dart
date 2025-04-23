import 'package:flutter/material.dart';
import '../constants.dart';

class ViewsScreen extends StatefulWidget {
  static String id = 'views_screen';

  const ViewsScreen({super.key});

  @override
  State<ViewsScreen> createState() => _ViewsScreenState();
}

class _ViewsScreenState extends State<ViewsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: size.height * 0.12,
            color: primaryGreen,
            child: Center(
              child: Text(
                'Views',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontWeight: FontWeight.w600,
                  fontSize: (size.width * 0.05).clamp(18, 20),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.015),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Viewed Products',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: 'qwerty',
                  ),
                ),

        ],
      ),
          )
    ])
    );
  }
}