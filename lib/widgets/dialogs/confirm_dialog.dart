import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/dialog_helper.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: DialogHeader(
        title: title,
        icon: icon ?? (isDestructive ? Icons.warning_amber_rounded : Icons.info_outline),
        color: isDestructive ? Colors.red : Colors.blue,
      ),
      width: 400,
      content: Text(
        content,
        style: GoogleFonts.inter(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
            onConfirm(); // Execute action
          },
          style: isDestructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

