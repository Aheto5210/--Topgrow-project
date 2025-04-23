import 'package:flutter/material.dart';
import 'package:top_grow_project/constants.dart';

class FilterHeader extends StatelessWidget {
  const FilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.05).clamp(16, 32),
        vertical: (screenHeight * 0.02).clamp(8, 16),
      ),
      decoration: const BoxDecoration(
        color: primaryGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: textScaler.scale(screenWidth * 0.06).clamp(20, 24),
                ),
              ),
              const Spacer(),
              Text(
                'Filter Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textScaler.scale(screenWidth * 0.05).clamp(16, 20),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'qwerty',
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          SizedBox(height: (screenHeight * 0.01).clamp(4, 8)),
        ],
      ),
    );
  }
}