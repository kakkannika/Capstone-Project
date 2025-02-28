import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/theme/theme.dart';

class Profile extends StatelessWidget {
  final String name;
  final String username;
  final String imagePath;

  const Profile({
    super.key,
    required this.name,
    required this.username,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: DertamSpacings.m),
        Text(
          name,
          style: DertamTextStyles.heading),
        SizedBox(height: DertamSpacings.s),
        Text('@$username',style: DertamTextStyles.label),
      ],
    );
  }
}