import 'package:flutter/material.dart';
import 'package:top_grow_project/constants.dart';


 class FarmerHomeScreen extends StatefulWidget {
    static String id = ' farmer_home_screen';
   const FarmerHomeScreen({super.key});

   @override
   State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
 }

 class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
        backgroundColor: iykBackgroundColor,  
     );
   }
 }
