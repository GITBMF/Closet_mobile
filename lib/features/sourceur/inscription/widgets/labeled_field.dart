import 'package:flutter/material.dart';

import '../../../../core/theme/closet_colors.dart';
import '../../../../core/theme/closet_text_styles.dart';

/// Champ de saisie CLOSET : label doré en capitales avec icône,
/// puis zone de texte crème arrondie.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    this.icone,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final IconData? icone;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icone != null) ...[
              Icon(icone, size: 16, color: ClosetColors.dore),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: ClosetTextStyles.labelChamp,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.onSurface.withValues(alpha: 0.12)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: ClosetTextStyles.saisie.copyWith(color: cs.onSurface),
            cursorColor: cs.primary,
            cursorWidth: 1.5,
            cursorHeight: 18,
            cursorRadius: const Radius.circular(1),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ClosetTextStyles.saisieHint.copyWith(
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

