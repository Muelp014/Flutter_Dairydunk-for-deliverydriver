import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color color; // Button background color
  final Color textColor; // Add this line for text color

  const MyButton({
    super.key,
    this.onTap,
    required this.text,
    this.color = Colors.blue, // Default button color if not provided
    this.textColor = Colors.white, // Default text color if not provided
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: color, // Use the color parameter here
            borderRadius: BorderRadiusDirectional.circular(8)),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor, // Use the text color parameter here
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}