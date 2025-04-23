// filter_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:top_grow_project/constants.dart';

class FilterBottomBar extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onSearch;
  final bool canSearch;
  final double screenWidth;
  final double screenHeight;

  const FilterBottomBar({
    super.key,
    required this.onClear,
    required this.onSearch,
    required this.canSearch,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.05).clamp(16, 32),
        vertical: (screenHeight * 0.02).clamp(8, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Clear button
          Expanded(
            child: ElevatedButton(
              onPressed: onClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: (screenHeight * 0.02).clamp(12, 16),
                ),
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: (screenWidth * 0.03).clamp(8, 12)),
          // Search button
          Expanded(
            child: ElevatedButton(
              onPressed: canSearch ? onSearch : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: (screenHeight * 0.02).clamp(12, 16),
                ),
              ),
              child: Text(
                'Search',
                style: TextStyle(
                  fontFamily: 'qwerty',
                  fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}