import 'package:flutter/material.dart';

class UserIcon extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;

  const UserIcon({
    super.key,
    required this.imageUrl,
    required this.size,
    this.borderWidth = 2,
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
