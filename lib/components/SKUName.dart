import 'package:flutter/material.dart';

class SKUName extends StatelessWidget {
  const SKUName({
    super.key,
    required this.name,
    required this.countType,
  });

  final String name;
  final String countType;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: name + " ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle, // keeps pill aligned
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    countType == "GOOD" ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                countType,
                style: TextStyle(
                  color: countType == "GOOD" ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      softWrap: true, // allows wrapping if skuName is long
    );
  }
}
