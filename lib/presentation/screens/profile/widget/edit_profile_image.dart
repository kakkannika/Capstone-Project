import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/theme/theme.dart';

class EditProfileImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onEdit;

  const EditProfileImage({
    super.key,
    required this.imagePath,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: DertamSpacings.xl + DertamSpacings.m,
          backgroundImage: AssetImage(imagePath),
        ),
        GestureDetector(
          onTap: onEdit,
          child: CircleAvatar(
            radius: DertamSpacings.s + 3,
            backgroundColor: DertamColors.primary,
            child: Icon(
              Icons.edit, 
              color: DertamColors.white, 
              size: DertamSpacings.m + 2,),
          ),
        ),
      ],
    );
  }
}