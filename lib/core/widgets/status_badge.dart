import 'package:flutter/material.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  
  const StatusBadge({
    super.key, 
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? ClosetColors.beige.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor != null ? Colors.transparent : ClosetColors.ligne),
      ),
      child: Text(
        text,
        style: ClosetTextStyles.badgePill.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
