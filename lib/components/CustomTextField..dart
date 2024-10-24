import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool hideText;
  final Widget? icon;
  final Widget? suffix;
  final Color? color;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final double borderRadius;
  final double borderWidth;
  final bool enabled;

  const CustomTextField._({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.enabled = true,
    required this.hintText,
    this.hideText = false,
    this.icon,
    this.suffix,
    this.color,
    this.backgroundColor,
    this.keyboardType,
    this.borderRadius = 30,
    this.borderWidth = 2,
  }) : assert(controller == null || onChanged == null,
            'Cannot provide both controller and onChanged');

  factory CustomTextField.withController({
    Key? key,
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hintText,
    bool hideText = false,
    bool enabled = true,
    Widget? icon,
    Widget? suffix,
    Color? color,
    Color? backgroundColor,
    TextInputType? keyboardType,
    double borderRadius = 30,
    double borderWidth = 2,
  }) {
    return CustomTextField._(
      key: key,
      controller: controller,
      hintText: hintText,
      hideText: hideText,
      focusNode: focusNode,
      icon: icon,
      enabled: enabled,
      suffix: suffix,
      color: color,
      backgroundColor: backgroundColor,
      keyboardType: keyboardType,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
    );
  }

  factory CustomTextField.withOnChanged({
    Key? key,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    required String hintText,
    bool hideText = false,
    bool enabled = true,
    Widget? icon,
    Widget? suffix,
    Color? color,
    Color? backgroundColor,
    TextInputType? keyboardType,
    double borderRadius = 30,
    double borderWidth = 2,
  }) {
    return CustomTextField._(
      key: key,
      onChanged: onChanged,
      hintText: hintText,
      hideText: hideText,
      focusNode: focusNode,
      icon: icon,
      enabled: enabled,
      suffix: suffix,
      color: color,
      backgroundColor: backgroundColor,
      keyboardType: keyboardType,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 20 : 5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: color ?? Theme.of(context).primaryColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        keyboardType: keyboardType,
        autofocus: false,
        obscureText: hideText,
        onChanged: onChanged,
        enabled: enabled,
        focusNode: focusNode,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon,
          suffixIcon: suffix,
          hintText: hintText,
          border: InputBorder.none,
          hintStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        ),
      ),
    );
  }
}
