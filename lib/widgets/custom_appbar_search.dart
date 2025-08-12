import 'package:flutter/material.dart';

class CustomAppbarSearch extends StatefulWidget {
  final String title;
  final TextEditingController controller;

  const CustomAppbarSearch({
    super.key,
    required this.title,
    required this.controller,
  });

  @override
  State<CustomAppbarSearch> createState() => _CustomAppbarSearchState();
}

class _CustomAppbarSearchState extends State<CustomAppbarSearch> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {}); // Updates suffix icon in real-time
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.of(context).textScaler;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.04).clamp(12, 20),
        vertical: 10,
      ).copyWith(top: MediaQuery.of(context).padding.top + 8),
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
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: textScaler.scale(screenWidth * 0.065).clamp(20, 28),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textScaler.scale(screenWidth * 0.045).clamp(16, 20),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'qwerty',
                    ),
                  ),
                ),
              ),
              // Balance the layout by reserving space equal to IconButton
              SizedBox(width: kMinInteractiveDimension),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.controller,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.black,
                size: 26,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
