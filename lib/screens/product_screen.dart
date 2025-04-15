import 'package:flutter/material.dart';


 class ProductScreen extends StatelessWidget {
    static String id = 'product_screen';
   const ProductScreen({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(

       body: Center(child: Text('Product Screen')),
     );
   }
 }
