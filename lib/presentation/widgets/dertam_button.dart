import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/theme/theme.dart';

class DertamButton extends StatelessWidget {
  const DertamButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    required this.buttonType,
    this.shape,
    this.height,
    this.width, // Add shape parameter
  });

  final VoidCallback onPressed;
  final String text;
  final ButtonType? buttonType;
  final IconData? icon;
  final OutlinedBorder? shape;
  final double? width;
  final double? height; // Define shape parameter

  @override
  Widget build(BuildContext context) {
    Color backGroundColor = buttonType == ButtonType.primary
        ? DertamColors.primary
        : DertamColors.white;

    BorderSide border = buttonType == ButtonType.primary
        ? BorderSide.none
        : BorderSide(color: DertamColors.greyLight, width: 2);

    Color textColor = buttonType == ButtonType.primary
        ? DertamColors.white
        : DertamColors.primary;

    Color iconColor = buttonType == ButtonType.primary
        ? DertamColors.white
        : DertamColors.primary;

    // Create the button icon - if any
    List<Widget> children = [];
    if (icon != null) {
      children.add(Icon(
        icon,
        size: 20,
        color: iconColor,
      ));
      children.add(const SizedBox(width: DertamSpacings.s));
    }
    // Create the button text
    Text buttonText =
        Text(text, style: DertamTextStyles.button.copyWith(color: textColor));
    children.add(buttonText);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backGroundColor,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: border,
            ), // Use the provided shape or default to RoundedRectangle
        side: border,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

enum ButtonType { primary, secondary }