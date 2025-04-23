import 'package:flutter/material.dart';

class CustomAppbarSearch extends StatefulWidget {
  final String title;
  final TextEditingController controller; // Changed from onChanged to controller

  const CustomAppbarSearch({super.key, required this.title, required this.controller});

  @override
  State<CustomAppbarSearch> createState() => _CustomAppbarSearchState();
}

class _CustomAppbarSearchState extends State<CustomAppbarSearch> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xff3B8751),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'qwerty',
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.controller, // Use the passed controller
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xff000000),
                size: 30,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xff000000),
                ),
                onPressed: () {
                  widget.controller.clear();
                  FocusScope.of(context).unfocus();
                },
              )
                  : null,
              hintText: 'Search for any product',
              hintStyle: const TextStyle(color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}