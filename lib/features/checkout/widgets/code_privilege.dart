import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/toasts.dart';
import '../brouillon_commande.dart';
import 'checkout_widgets.dart';

/// Code privilège — maquette `16:3448` : libellé Lato 10, saisie serif 14,
/// « Appliquer » en action texte (pas un CTA plein). Facultatif.
class ChampCodePrivilege extends ConsumerWidget {
  const ChampCodePrivilege({super.key, required this.controller});

  final TextEditingController controller;

  void _appliquer(WidgetRef ref) {
    final code = controller.text.trim();
    if (code.isEmpty) return;

    final applique =
        ref.read(brouillonCommandeProvider.notifier).appliquerCodePrivilege(code);

    if (applique) {
      final l10n = ref.read(l10nProvider);
      toastSucces(ref, l10n.codeEnregistreTitre, l10n.remiseCalculeeAuPaiementMessage);
    }
  }

  void _retirer(WidgetRef ref) {
    controller.clear();
    ref.read(brouillonCommandeProvider.notifier).retirerCodePrivilege();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final applique =
        ref.watch(brouillonCommandeProvider).codePrivilege.isNotEmpty;
    final encreChamp = ClosetTextStyles.prix.copyWith(
      fontWeight: FontWeight.w300,
      color: context.closetEncre,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.codePrivilegeLabel,
              style: ClosetTextStyles.meta.copyWith(
                color: ClosetColors.vert,
              ),
            ),
            const Spacer(),
            Text(
              l10n.facultatifLabel,
              style: ClosetTextStyles.mention.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.p8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: controller,
                  enabled: !applique,
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _appliquer(ref),
                  style: encreChamp,
                  cursorColor: ClosetColors.vert,
                  decoration: InputDecoration(
                    hintText: l10n.cerclePrivilegeHint,
                    hintStyle: encreChamp.copyWith(
                      color: ClosetColors.placeholderGris,
                    ),
                    filled: true,
                    fillColor: applique
                        ? ClosetColors.emeraude100
                        : context.closetChamp,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p16,
                      vertical: AppSpacing.p12,
                    ),
                    border: bordureChamp(ClosetColors.fond300),
                    enabledBorder: bordureChamp(ClosetColors.fond300),
                    disabledBorder: bordureChamp(ClosetColors.emeraude100),
                    focusedBorder: bordureChamp(ClosetColors.vert),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.p8),
            TextButton(
              onPressed:
                  applique ? () => _retirer(ref) : () => _appliquer(ref),
              style: TextButton.styleFrom(
                minimumSize: const Size(72, 42),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor:
                    applique ? ClosetColors.taupe : ClosetColors.fond400,
              ),
              child: Text(
                applique ? l10n.retirerLabel : l10n.appliquerLabel,
                style: ClosetTextStyles.actionPetite.copyWith(
                  color: applique ? ClosetColors.taupe : ClosetColors.fond400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
