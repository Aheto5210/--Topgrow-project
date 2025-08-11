import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';


class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         automaticallyImplyLeading: false,
         centerTitle: true,
         title: AutoSizeText(
           'Orders',
           style: const TextStyle(
             fontFamily: 'qwerty',
             fontWeight: FontWeight.w600,
             fontSize: 22,
             color: Colors.white,
           ),
           maxLines: 1,
           minFontSize: 16,
           overflow: TextOverflow.ellipsis,
         ),
         backgroundColor: const Color(0xff3B8751),
       ),
    );
  }
}
