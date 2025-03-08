import 'package:flutter/material.dart';

class DertamTabs extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> children;
  final Color activeColor;
  final Color inactiveColor;

  const DertamTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.activeColor = const Color(0xFF386FA4),
    this.inactiveColor = Colors.grey,
  }) : assert(tabs.length == children.length, 'Tabs and children must have same length');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            labelColor: activeColor,
            unselectedLabelColor: inactiveColor,
            indicatorColor: activeColor,
            indicatorWeight: 3,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            children: children,
          ),
        ),
      ],
    );
  }
}