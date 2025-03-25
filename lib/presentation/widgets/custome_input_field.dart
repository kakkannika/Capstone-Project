import 'package:flutter/material.dart';
import 'package:tourism_app/theme/theme.dart';
class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DertamSpacings.m, vertical: DertamSpacings.s-8),
      decoration: BoxDecoration(
      color: DertamColors.white,
      borderRadius: BorderRadius.circular(DertamSpacings.radius),
      
      boxShadow: [
        BoxShadow(
          color: DertamColors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,hintStyle: TextStyle(color: DertamColors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }
}