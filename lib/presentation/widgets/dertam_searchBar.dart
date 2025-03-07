import 'package:flutter/material.dart';

class TamSearchbar extends StatefulWidget {
  final Function(String text) onSearchChanged;
  final VoidCallback onBackPressed;

  const TamSearchbar(
      {super.key, required this.onSearchChanged, required this.onBackPressed});

  @override
  State<TamSearchbar> createState() => _DamSearchbarState();
}

class _DamSearchbarState extends State<TamSearchbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destination',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}