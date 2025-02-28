import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/widgets/dertam_dialog_botton.dart';
import 'package:tourism_app/presentation/theme/theme.dart';

class DertamDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<Widget>? contentWidgets;
  final List<DertamDialogButton> actions;
  final bool centerTitle;

  const DertamDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidgets,
    required this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DertamSpacings.radius),
      ),
      title: Text(
        title,
        textAlign: centerTitle ? TextAlign.center : TextAlign.left,
        style: DertamTextStyles.title.copyWith(
          color: DertamColors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: DertamSpacings.m,
        vertical: DertamSpacings.s,
      ),
      content: contentWidgets != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: contentWidgets!,
            )
          : content != null
              ? Text(
                  content!,
                  style: DertamTextStyles.body.copyWith(
                    color: DertamColors.grey,
                  ),
                )
              : null,
      actionsPadding: EdgeInsets.all(DertamSpacings.m),
      actions: actions,
    );
  }
}