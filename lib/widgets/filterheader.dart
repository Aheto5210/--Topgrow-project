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
        horizontal: (screenWidth * 0.05).clamp(16, 28),
        vertical: (screenHeight * 0.015).clamp(10, 18),
      ).copyWith(top: MediaQuery.of(context).padding.top + 8),
      decoration: const BoxDecoration(
        color: primaryGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Close Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: textScaler.scale(screenWidth * 0.065).clamp(22, 28),
                ),
              ),

              // Title in center
              Expanded(
                child: Center(
                  child: Text(
                    'Filter Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                      textScaler.scale(screenWidth * 0.05).clamp(16, 20),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'qwerty',
                    ),
                  ),
                ),
              ),

              // Placeholder to balance close button width
              SizedBox(
                width: kMinInteractiveDimension,
              ),
            ],
          ),
          SizedBox(height: (screenHeight * 0.01).clamp(4, 8)),
        ],
      ),
    );
  }
}
