import 'package:flutter/material.dart';
import 'package:tourism_app/theme/theme.dart';

class TripItem extends StatelessWidget {
  final String title;
  final String places;
  final String status;
  final String imagePath;
  final VoidCallback onTap;

  const TripItem({
    super.key,
    required this.title,
    required this.places,
    required this.status,
    required this.imagePath,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return DertamColors.green;
      case 'upcoming':
        return DertamColors.primary;
      case 'planning':
        return DertamColors.orange;
      default:
        return DertamColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(DertamSpacings.radius),
          child: Image.asset(
            imagePath,
            width: DertamSpacings.xl + DertamSpacings.m,
            height: DertamSpacings.xl + DertamSpacings.m,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: DertamSpacings.xl + DertamSpacings.m,
                height: DertamSpacings.xl + DertamSpacings.m,
                color: DertamColors.neutralLighter,
                child: Icon(Icons.image_not_supported, color: DertamColors.grey),
              );
            },
          ),
        ),
        title: Text(
          title, 
          style: DertamTextStyles.body.copyWith(
            fontWeight: FontWeight.w500,
            color: DertamColors.black,
          ),
        ),
        subtitle: Text(
          places, 
          style: DertamTextStyles.label.copyWith(
            color: DertamColors.grey,
          ),
        ),
        trailing: Text(
          status,
          style: DertamTextStyles.label.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}