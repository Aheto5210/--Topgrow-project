import 'package:flutter/material.dart';

class CustomAppbarSearch extends StatefulWidget {
  final String title;

  const CustomAppbarSearch({super.key, required this.title});

  @override
  State<CustomAppbarSearch> createState() => _CustomAppbarSearchState();
}

class _CustomAppbarSearchState extends State<CustomAppbarSearch> {
  final TextEditingController _searchcontroller = TextEditingController();

  @override
  void dispose() {
    _searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
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
                icon: Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              Text(
                widget.title,
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
          TextField(
            controller: _searchcontroller,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xff000000),
                size: 30,
              ),
              hintText: 'Search for any product',
              hintStyle: TextStyle(color: Colors.grey),
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
