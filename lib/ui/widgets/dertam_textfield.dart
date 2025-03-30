// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:tourism_app/theme/theme.dart';

class DertamTextfield extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final VoidCallback? onVisibilityToggle;
  final bool obscureText;
  final bool isPhoneNumber;
  final String? Function(String?)? validator;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Function(String)? onChanged;
  final bool enabled;

  const DertamTextfield({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.isPassword = false,
    this.onVisibilityToggle,
    this.obscureText = false,
    this.isPhoneNumber = false,
    this.validator,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = Colors.blue,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: textColor),
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          filled: true,
          fillColor: backgroundColor,
          prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DertamSpacings.radius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DertamSpacings.radius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DertamSpacings.radius),
            borderSide: BorderSide(color: focusedBorderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DertamSpacings.radius),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DertamSpacings.radius),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
        ),
      ),
    );
  }
}