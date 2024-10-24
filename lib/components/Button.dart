import 'package:flutter/material.dart';

import '../util/constant.dart';

class Button extends StatelessWidget {
  const Button(
      {super.key,
      required this.onPressed,
      required this.text,
      this.style,
      this.borderRadius = 20});

  final String text;
  final void Function() onPressed;
  final String? style;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    ButtonStyle primaryStyle = ElevatedButton.styleFrom(
      // elevation: 0,
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
    ButtonStyle secondaryStyle = ElevatedButton.styleFrom(
      // elevation: 0,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    return Container(
      decoration: style != null && style == buttonSecondary
          ? BoxDecoration(
              border: Border.all(
                width: 1,
                color: primaryColor,
              ),
              borderRadius: BorderRadius.circular(20))
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style != null && style == buttonSecondary
            ? secondaryStyle
            : primaryStyle,
        child: Text(
          text,
          style: TextStyle(
              color: style != null && style == buttonSecondary
                  ? const Color.fromRGBO(52, 73, 94, 1)
                  : Colors.white),
        ),
      ),
    );
  }
}
