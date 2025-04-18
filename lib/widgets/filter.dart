import 'package:flutter/material.dart';

class Filter extends StatelessWidget {


  const Filter({super.key,});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Color(0xff3B8751),

          ), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
              Row(
              children: [
              IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              Text(
              'Filter Products',
              style: TextStyle(
              color: Color(0xffFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'qwerty',
              ),
              ),
              const Spacer(flex: 2),
              ],
              ),
              SizedBox(height: 10),
            ])
      ),
    );
  }
}
