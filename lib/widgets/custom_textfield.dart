import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.errorText,
    this.onChanged,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final screenWidth = MediaQuery.of(context).size.width;

    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: const Color.fromRGBO(121, 121, 121, 1),
          fontSize: textScaler.scale(screenWidth * 0.045).clamp(16, 18),
          fontWeight: FontWeight.w400,
          fontFamily: 'Qwerty',
        ),
        errorText: widget.errorText,
        errorStyle: TextStyle(
          color: Colors.redAccent,
          fontSize: textScaler.scale(screenWidth * 0.035).clamp(12, 14),
          fontFamily: 'Qwerty',
        ),
        filled: true,
        fillColor: widget.enabled
            ? const Color.fromRGBO(247, 247, 247, 1)
            : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromRGBO(59, 135, 81, 1),
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: (screenWidth * 0.04).clamp(12, 16),
          vertical: (screenWidth * 0.04).clamp(12, 16),
        ),
      ),
      style: TextStyle(
        fontSize: textScaler.scale(screenWidth * 0.045).clamp(16, 18),
        fontFamily: 'Qwerty',
        color: Colors.black87,
      ),
      textInputAction: TextInputAction.done,
      onTapOutside: (event) {
        _focusNode.unfocus();
      },
    );
  }
}