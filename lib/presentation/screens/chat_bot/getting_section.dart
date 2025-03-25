import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tourism_app/theme/theme.dart';

class GreetingSection extends StatefulWidget {
  final Function(String) onSuggestionSelected;

  const GreetingSection({super.key, required this.onSuggestionSelected});

  @override
  _GreetingSectionState createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  String _displayedText = "";
  final String _fullText = "Hello, Virakbott";
  late Timer _typingTimer;
  int _charIndex = 0;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_charIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _showSuggestions = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayedText,
             style: DertamTextStyles.heading.copyWith(
              color: DertamColors.neutralDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: DertamSpacings.s),
          if (_showSuggestions) ...[
            Text(
              "Don't know what to ask? Try these examples:",
              style: DertamTextStyles.title.copyWith(
                color: DertamColors.neutralLight,
              ),
            ),
            SizedBox(height: DertamSpacings.m),
            Column(
              children: [
                _buildSuggestionCard("Show me some nearby restaurants with good reviews."),
                _buildSuggestionCard("What are the top three tourist attractions in this city?"),
                _buildSuggestionCard("Suggest a museum with interesting exhibits and convenient hours."),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion) {
    return GestureDetector(
      onTap: () => widget.onSuggestionSelected(suggestion),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: DertamSpacings.s / 3),
        padding: const EdgeInsets.symmetric(
          horizontal: DertamSpacings.m,
          vertical: DertamSpacings.s,),
        decoration: BoxDecoration(
          color: DertamColors.backgroundAccent,
          borderRadius: BorderRadius.circular(DertamSpacings.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                suggestion,
                style: DertamTextStyles.body.copyWith(
                  color: DertamColors.neutralDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}