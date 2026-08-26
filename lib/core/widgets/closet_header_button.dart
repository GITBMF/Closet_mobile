import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_layout.dart';
import '../theme/closet_text_styles.dart';

/// Bouton rond d'en-tête, dimensionné selon [ClosetLayout].
///
/// La zone tactile reste ≥ 44 pt (48 sur petit écran). Le disque visible
/// s'adapte pour ne pas coincer sélection / notifications / retour contre
/// l'encoche ou le bord du téléphone.
class ClosetBoutonHeader extends StatelessWidget {
  const ClosetBoutonHeader({
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
    this.pastille,
    this.couleurIcone,
    this.fond,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final int? pastille;
  final Color? couleurIcone;
  final Color? fond;

  @override
  Widget build(BuildContext context) {
    final layout = ClosetLayout.of(context);
    final disque = layout.boutonHeader;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: layout.cibleTactile,
            height: layout.cibleTactile,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: disque,
                    height: disque,
                    decoration: BoxDecoration(
                      color: fond ?? ClosetColors.carteFond,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ClosetColors.fond300,
                        width: AppStroke.fin,
                      ),
                    ),
                    child: Icon(
                      icone,
                      size: layout.iconeHeader,
                      color: couleurIcone ?? ClosetColors.vert,
                    ),
                  ),
                  if (pastille != null)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.p4),
                          constraints: const BoxConstraints(minWidth: 16),
                          decoration: const BoxDecoration(
                            color: ClosetColors.vert,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pastille',
                            textAlign: TextAlign.center,
                            style: ClosetTextStyles.micro.copyWith(
                              color: ClosetColors.creme,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
