import 'package:flutter/material.dart';
import 'package:tourism_app/core/theme.dart';

class DertamDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? dertamColor;
  final bool isDestructive;
  final bool hasBackground;

  const DertamDialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.dertamColor,
    this.isDestructive = false,
    this.hasBackground = false,
  });

  @override
    Widget build(BuildContext context) {
    final Color defaultColor = isDestructive
        ? DertamColors.red
        : DertamColors.lightBlue;

    final Color textColor = dertamColor ?? defaultColor;
    final Color? backgroundColor = hasBackground && dertamColor != null
        ? dertamColor!.withOpacity(0.1)
        : null;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: DertamSpacings.m, vertical: DertamSpacings.s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DertamSpacings.radius),
        ),
      ),
      child: Text(
        text,
        style: DertamTextStyles.button.copyWith(color: textColor)
      ),
    );
  }
}