import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/toasts.dart';
import '../brouillon_commande.dart';

/// Saisie du code privilège — affichée à l'étape de paiement uniquement.
class ChampCodePrivilege extends ConsumerWidget {
  const ChampCodePrivilege({super.key, required this.controller});

  final TextEditingController controller;

  void _appliquer(WidgetRef ref) {
    final code = controller.text.trim();
    if (code.isEmpty) return;

    final applique =
        ref.read(brouillonCommandeProvider.notifier).appliquerCodePrivilege(code);

    if (applique) {
      toastSucces(
        ref,
        'Code enregistré',
        'La remise sera calculée par ClosET au paiement.',
      );
    }
  }

  void _retirer(WidgetRef ref) {
    controller.clear();
    ref.read(brouillonCommandeProvider.notifier).retirerCodePrivilege();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applique =
        ref.watch(brouillonCommandeProvider).codePrivilege.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                size: 13,
                color: ClosetColors.fond500,
              ),
              const SizedBox(width: AppSpacing.gapChip),
              Text(
                'Code privilège'.toUpperCase(),
                style: ClosetTextStyles.meta.copyWith(
                  letterSpacing: 1.30,
                  color: ClosetColors.fond500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: controller,
                    enabled: !applique,
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _appliquer(ref),
                    style: ClosetTextStyles.nomProduit.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: 'cercle-privilège',
                      hintStyle: ClosetTextStyles.nomProduit.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: ClosetColors.placeholderGris,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p12,
                      ),
                      border: _bordure(),
                      enabledBorder: _bordure(),
                      focusedBorder: _bordure(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.p16),
              SizedBox(
                width: 114,
                height: 38,
                child: Material(
                  color: applique ? ClosetColors.emeraude100 : ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: applique ? () => _retirer(ref) : () => _appliquer(ref),
                    child: Center(
                      child: Text(
                        applique ? 'Retirer' : 'Appliquer',
                        style: ClosetTextStyles.actionPetite.copyWith(
                          color: applique
                              ? ClosetColors.vert
                              : ClosetColors.blanc,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _bordure() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: ClosetColors.fond300,
          width: AppStroke.fin,
        ),
      );
}
