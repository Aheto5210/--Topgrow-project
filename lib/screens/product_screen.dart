import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  static String id = 'product_screen';

  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Color(0xff3B8751),
        automaticallyImplyLeading: false,

      ),
      body: Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
             color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(children: [
                Icon(Icons.close, color: Colors.white),
                 Text('Add Product')
              ],)
            ],
          ),
        ),
      ),
    );
  }
}
