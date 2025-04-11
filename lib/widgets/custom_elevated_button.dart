import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text; // Text to display when not loading
  final VoidCallback? onPressed; // Callback for button press, nullable
  final bool isLoading; // Indicates if the button is in a loading state

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false, // Default to false (not loading)
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(59, 135, 81, 1), // Green background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 15,
          ),
        ),
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white, // White indicator to match text
                strokeWidth: 2.0,
              ),
            )
                : Text(
              text,
              style: const TextStyle(
                fontFamily: 'qwerty',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ), // Show text when not loading
          ],
        ),
      ),
    );
  }
}