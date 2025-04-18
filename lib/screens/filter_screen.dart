import 'package:flutter/material.dart';
import 'package:top_grow_project/widgets/filter.dart';
import 'package:top_grow_project/widgets/filter_text_field.dart';

 class FilterScreen extends StatefulWidget {
   static String  id = 'filter_screen';
   const FilterScreen({super.key});

   @override
   State<FilterScreen> createState() => _FilterScreenState();
 }

 class _FilterScreenState extends State<FilterScreen> {
   @override
   Widget build(BuildContext context) {
     return SafeArea(
       child: Scaffold(
         body:Column(
           children: [
             Filter(),
             SizedBox(height: 20),
             FilterTextField(),
           ],
         )
       ),
     );
   }
 }
