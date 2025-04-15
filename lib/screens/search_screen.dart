import 'package:flutter/material.dart';

import '../widgets/custom_appbar_search.dart';

 class SearchScreen extends StatefulWidget {
    static String id = 'search_screen';
   const SearchScreen({super.key});

   @override
   State<SearchScreen> createState() => _SearchScreenState();
 }

 class _SearchScreenState extends State<SearchScreen> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
         body:  SafeArea(
           child: Column(
             children: [
               CustomAppbarSearch(title: 'Products/Items',),
             ],
           ),
         ),
     );
   }
 }





