import 'package:flutter/material.dart';
import 'package:top_grow_project/screens/filter_screen.dart';
import 'package:top_grow_project/screens/search_screen.dart';

class CustomAppbar extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const CustomAppbar({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xff3B8751),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Spacer(flex: 2),
                Text(
                  'What are you looking for?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                    fontFamily: 'qwerty',
                    color: Colors.white,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              onTap: (){
           Navigator.pushNamed(context, SearchScreen.id);
              },
              readOnly: true,
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.grey,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, FilterScreen.id);                  },
                  icon: const Icon(Icons.tune_outlined),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
