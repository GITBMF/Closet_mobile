import 'package:flutter/material.dart';
import '../theme/closet_colors.dart';

class ClosetChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasCloseIcon;
  final VoidCallback? onTap;
  final VoidCallback? onCloseTap;

  const ClosetChip({
    super.key, 
    required this.label,
    this.isActive = false,
    this.hasCloseIcon = false,
    this.onTap,
    this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
        color: isActive ? ClosetColors.vertFonce : ClosetColors.creme,
        border: Border.all(color: isActive ? Colors.transparent : ClosetColors.ligne),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : ClosetColors.noir,
            ),
          ),
          if (hasCloseIcon) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onCloseTap ?? onTap,
              child: Icon(
                Icons.close,
                size: 14,
                color: isActive ? Colors.white : ClosetColors.noir,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
