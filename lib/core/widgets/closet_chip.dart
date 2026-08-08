import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Puce de filtre — maquette « Explorer par univers » (`11:30`).
///
/// Actif : vert profond plein, libellé crème, sans bordure.
/// Inactif : fond crème, bordure dorée fine, libellé encre.
/// Les deux états sont en pilule pleine.
class ClosetChip extends StatelessWidget {
  const ClosetChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.selectionnee = false,
    this.hasCloseIcon = false,
    this.onTap,
    this.onCloseTap,
  });

  final String label;
  final bool isActive;
  final bool selectionnee;
  final bool hasCloseIcon;
  final VoidCallback? onTap;
  final VoidCallback? onCloseTap;

  bool get _active => isActive || selectionnee;

  @override
  Widget build(BuildContext context) {
    final couleurTexte = _active ? ClosetColors.creme : ClosetColors.noir;

    return Semantics(
      button: true,
      selected: _active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.bouton),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 30,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p8,
          ),
          decoration: BoxDecoration(
            color: _active ? ClosetColors.vert : Colors.white,
            border: Border.all(
              color: _active ? Colors.transparent : ClosetColors.fond300,
              width: AppStroke.fin,
            ),
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: ClosetTextStyles.corps.copyWith(color: couleurTexte),
              ),
              if (hasCloseIcon) ...[
                const SizedBox(width: AppSpacing.gapChip),
                GestureDetector(
                  onTap: onCloseTap ?? onTap,
                  child: Icon(Icons.close, size: 14, color: couleurTexte),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
