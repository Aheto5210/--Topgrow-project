 import 'package:flutter/material.dart';

final  iykBackgroundColor = Colors.green.shade50;
 // Static constants
 class Constants {
   static const List<String> categories = [
     'Vegetables',
     'Fruits',
     'Grains',
     'Dairy',
     'Meat',
     'Herbs',
     'Processed Foods'
   ];

   static const List<String> sizes = [
     '250g', '500g', '1kg', '5kg', '10kg', '500ml', '1L', '2L',
     'Half Dozen', 'Dozen', 'Per kg', 'Small', 'Medium', 'Large'
   ];
 }



 // App-wide constants for consistent theming
 const Color primaryGreen = Color(0xff3B8751); // Primary green for buttons and accents
 const double borderRadius = 12.0; // Standard border radius for UI elements



 class SearchConstants {
   static const Color primaryGreen = Color(0xff3B8751);
   static const double borderRadius = 12.0;
   static const double standardPadding = 16.0;
 }