import 'package:flutter/material.dart';

 class ProfileScreen extends StatelessWidget {
    static String id = 'profile_screen';
   const ProfileScreen({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body:  Center(child: Text('Profile Screen')),
     );
   }
 }
