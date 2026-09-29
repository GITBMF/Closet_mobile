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

    final applique = ref
        .read(brouillonCommandeProvider.notifier)
        .appliquerCodePrivilege(code);

    if (applique) {
      final l10n = ref.read(l10nProvider);
      toastSucces(
        ref,
        l10n.codeEnregistreTitre,
        l10n.remiseCalculeeAuPaiementMessage,
      );
    }
  }

  void _retirer(WidgetRef ref) {
    controller.clear();
    ref.read(brouillonCommandeProvider.notifier).retirerCodePrivilege();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final applique = ref
        .watch(brouillonCommandeProvider)
        .codePrivilege
        .isNotEmpty;
    final encreChamp = ClosetTextStyles.prix.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: context.closetEncre,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ClosetColors.emeraude100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_activity_outlined,
                size: 22,
                color: ClosetColors.vert,
              ),
            ),
            const SizedBox(width: AppSpacing.p12),
            Expanded(
              child: Text(
                l10n.codePrivilegeLabel,
                style: ClosetTextStyles.titreSection.copyWith(
                  color: context.closetEncre,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.p12),
        Text(
          l10n.codePrivilegeAccroche,
          style: ClosetTextStyles.corps.copyWith(
            fontSize: 15,
            height: 1.45,
            color: context.closetSecondaire,
          ),
        ),
        const SizedBox(height: AppSpacing.p20),
        TextField(
          controller: controller,
          enabled: !applique,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _appliquer(ref),
          style: encreChamp,
          cursorColor: context.closetVert,
          decoration: InputDecoration(
            hintText: l10n.codePrivilegeSaisir,
            hintStyle: encreChamp.copyWith(
              fontSize: 17,
              color: context.closetSecondaire,
            ),
            filled: true,
            fillColor: applique
                ? ClosetColors.emeraude100
                : context.closetChamp,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p20,
              vertical: AppSpacing.p20,
            ),
            border: bordureChamp(ClosetColors.fond300),
            enabledBorder: bordureChamp(ClosetColors.fond300),
            disabledBorder: bordureChamp(ClosetColors.emeraude100),
            focusedBorder: bordureChamp(context.closetVert),
          ),
        ),
        const SizedBox(height: AppSpacing.p16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Material(
            color: applique ? Colors.transparent : context.closetAction,
            shape: StadiumBorder(
              side: applique
                  ? BorderSide(color: context.closetSecondaire)
                  : BorderSide.none,
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: applique ? () => _retirer(ref) : () => _appliquer(ref),
              child: Center(
                child: Text(
                  applique ? l10n.retirerLabel : l10n.appliquerLabel,
                  style: ClosetTextStyles.bouton.copyWith(
                    color: applique ? context.closetSecondaire : context.closetActionTexte,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Feuille de saisie du code privilège, ouverte depuis Mon espace : le champ
/// n'apparaît plus dans le tunnel de paiement.
void afficherCodePrivilege(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FeuilleCodePrivilege(),
  );
}

class _FeuilleCodePrivilege extends ConsumerStatefulWidget {
  const _FeuilleCodePrivilege();

  @override
  ConsumerState<_FeuilleCodePrivilege> createState() =>
      _FeuilleCodePrivilegeState();
}

class _FeuilleCodePrivilegeState extends ConsumerState<_FeuilleCodePrivilege> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(brouillonCommandeProvider).codePrivilege,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.p24,
          AppSpacing.p20,
          AppSpacing.p24,
          AppSpacing.p32,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.p20),
                    decoration: BoxDecoration(
                      color: ClosetColors.carteBordure,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ChampCodePrivilege(controller: _controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
