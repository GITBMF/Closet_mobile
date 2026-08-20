import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Un moyen de retrait proposé par la maquette `32:511`.
@immutable
class MoyenRetrait {
  const MoyenRetrait({
    required this.id,
    required this.libelle,
    required this.compte,
    required this.icone,
  });

  final String id;
  final String libelle;

  /// Numéro rattaché. Jamais affiché en entier hors de cet écran.
  final String compte;

  final IconData icone;
}

/// TODO(backend): les moyens de retrait doivent venir du profil sourceur.
const List<MoyenRetrait> moyensRetrait = [
  MoyenRetrait(
    id: 'orange',
    libelle: 'Orange Money',
    compte: '699000000',
    icone: Icons.phone_android_rounded,
  ),
  MoyenRetrait(
    id: 'mtn',
    libelle: 'MTN Mobile Money',
    compte: '677000000',
    icone: Icons.phone_iphone_rounded,
  ),
  MoyenRetrait(
    id: 'visa',
    libelle: 'Carte Visa',
    compte: '4864',
    icone: Icons.credit_card_rounded,
  ),
];

/// Ouvre le panneau « Méthode de retrait de fonds » — maquette `32:511`.
///
/// Posé au-dessus de l'espace sourceur, il choisit le moyen puis lance le
/// tunnel de transaction en mode retrait.
Future<void> afficherMethodeRetrait(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _MethodeRetraitSheet(),
  );
}

class _MethodeRetraitSheet extends ConsumerStatefulWidget {
  const _MethodeRetraitSheet();

  @override
  ConsumerState<_MethodeRetraitSheet> createState() =>
      _MethodeRetraitSheetState();
}

class _MethodeRetraitSheetState
    extends ConsumerState<_MethodeRetraitSheet> {
  String _choisi = moyensRetrait.first.id;

  @override
  Widget build(BuildContext context) {
    final revenus = ref.watch(revenusSourceurProvider);
    final pieces = ref.watch(mesPiecesProvider);
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ClosetColors.blanc,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.p24,
            AppSpacing.p20,
            AppSpacing.p24,
            AppSpacing.p20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ClosetColors.caseVide,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p20),
              Text(
                'Methode de retrait de fonds',
                style: ClosetTextStyles.libelle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.p16),
              Text(
                'pièces en vente : '
                '${pieces.maybeWhen(data: _compteEnVente, orElse: () => '--')} '
                'pièces',
                style: ClosetTextStyles.actionPetite.copyWith(
                  letterSpacing: 0.30,
                  color: ClosetColors.fond300,
                ),
              ),
              const SizedBox(height: AppSpacing.p12),
              const Divider(
                color: ClosetColors.caseVide,
                height: AppStroke.fin,
                thickness: AppStroke.fin,
              ),
              const SizedBox(height: AppSpacing.p12),
              Text(
                'à reverser : '
                '${revenus.maybeWhen(data: (r) => formatPrixFcfa(r.solde.toDouble()), orElse: () => '--')}',
                style: ClosetTextStyles.actionPetite.copyWith(
                  letterSpacing: 0.30,
                  color: ClosetColors.fond300,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              for (final moyen in moyensRetrait)
                _LigneMoyen(
                  moyen: moyen,
                  choisi: moyen.id == _choisi,
                  onTap: () => setState(() => _choisi = moyen.id),
                ),
              const SizedBox(height: AppSpacing.p24),
              SizedBox(
                height: 44,
                child: Material(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => _valider(context, revenus, user),
                    child: Center(
                      child: Text(
                        'Valider la methode de retrait',
                        style: ClosetTextStyles.bouton.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.blanc,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ferme le panneau. Les retraits sont versés par ClosET : l'API mobile
  /// n'expose pas de déclenchement de virement.
  void _valider(
    BuildContext context,
    AsyncValue<RevenusSourceur> revenus,
    ClosetUser? user,
  ) {
    Navigator.of(context).pop();
    toastInfo(
      ref,
      'Retraits gérés par ClosET',
      'Les virements sont émis une fois vos pièces vendues. '
          'L’historique affiché correspond aux paiements réellement versés.',
    );
  }

  /// Nombre de pièces effectivement en vente, sur deux chiffres.
  static String _compteEnVente(List<PieceDeposee> pieces) {
    final enVente = pieces.where((p) => p.statut == StatutPiece.publiee).length;
    return enVente.toString().padLeft(2, '0');
  }
}

/// Ligne de moyen : vignette 45 × 32 cerclée, libellé, coche de sélection.
class _LigneMoyen extends StatelessWidget {
  const _LigneMoyen({
    required this.moyen,
    required this.choisi,
    required this.onTap,
  });

  final MoyenRetrait moyen;
  final bool choisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: choisi,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ClosetColors.blanc,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: choisi
                        ? ClosetColors.vert
                        : ClosetColors.caseVide,
                    width: AppStroke.fin,
                  ),
                ),
                child: Icon(moyen.icone, size: 18, color: ClosetColors.vert),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Text(
                  moyen.libelle,
                  style: ClosetTextStyles.libelle.copyWith(
                    color: ClosetColors.pinTexte,
                  ),
                ),
              ),
              Icon(
                choisi
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: choisi ? ClosetColors.vert : ClosetColors.ligne,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
