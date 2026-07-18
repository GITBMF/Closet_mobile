import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Chip de sélection CLOSET : vert sapin quand sélectionnée, crème sinon.
class ClosetChip extends StatelessWidget {
  const ClosetChip({
    super.key,
    required this.label,
    required this.selectionnee,
    required this.onTap,
  });

  final String label;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selectionnee ? ClosetColors.vert : ClosetColors.creme,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: selectionnee ? ClosetColors.vert : ClosetColors.bordure,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Text(
            label,
            style: ClosetTextStyles.corps.copyWith(
              color: selectionnee
                  ? ClosetColors.texteSurVert
                  : ClosetColors.noir,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
