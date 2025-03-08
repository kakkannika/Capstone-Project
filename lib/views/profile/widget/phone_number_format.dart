import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits and '+'
    final newString = newValue.text.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure '+' is only at the start
    if (newString.contains('+') && !newString.startsWith('+')) {
      return oldValue;
    }
    
    // Maximum length check (e.g., +855 + 9 digits)
    if (newString.length > 13) {
      return oldValue;
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}