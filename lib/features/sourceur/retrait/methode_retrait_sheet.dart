import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_filet.dart';
import '../../../core/widgets/marque_paiement.dart';
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
List<MoyenRetrait> moyensRetraitPour(ClosetL10n l10n) => [
      MoyenRetrait(
        id: 'orange',
        libelle: l10n.moyenOrangeMoney,
        compte: '699000000',
        icone: Icons.phone_android_rounded,
      ),
      MoyenRetrait(
        id: 'mtn',
        libelle: l10n.moyenMtnMobileMoney,
        compte: '677000000',
        icone: Icons.phone_iphone_rounded,
      ),
      MoyenRetrait(
        id: 'visa',
        libelle: l10n.moyenCarteVisa,
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
  String _choisi = 'orange';

  @override
  void initState() {
    super.initState();
    final profil = ref.read(sourceurRepositoryProvider).profile;
    final enregistre = profil?.moyenPaiement.toLowerCase() ?? '';
    if (enregistre.contains('mtn')) {
      _choisi = 'mtn';
    } else if (enregistre.contains('orange')) {
      _choisi = 'orange';
    } else if (enregistre.contains('visa') || enregistre.contains('carte')) {
      _choisi = 'visa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
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
                l10n.methodeRetraitTitre,
                style: ClosetTextStyles.libelle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.p16),
              Text(
                l10n.piecesEnVente(
                  pieces.maybeWhen(data: _compteEnVente, orElse: () => '0'),
                ),
                style: ClosetTextStyles.actionPetite.copyWith(
                  letterSpacing: 0.30,
                  color: ClosetColors.fond300,
                ),
              ),
              const SizedBox(height: AppSpacing.p12),
              const ClosetFilet(couleur: ClosetColors.caseVide),
              const SizedBox(height: AppSpacing.p12),
              Text(
                l10n.aReverser(
                  revenus.maybeWhen(
                    data: (r) => formatPrixFcfa(r.enAttente.toDouble()),
                    orElse: () => '--',
                  ),
                ),
                style: ClosetTextStyles.actionPetite.copyWith(
                  letterSpacing: 0.30,
                  color: ClosetColors.fond300,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              for (final moyen in _moyensAffiches(l10n))
                _LigneMoyen(
                  moyen: moyen,
                  choisi: moyen.id == _choisi,
                  onTap: () => setState(() => _choisi = moyen.id),
                ),
              const SizedBox(height: AppSpacing.p24),
              SizedBox(
                height: 44,
                child: Material(
                  color: context.closetAction,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => _valider(context, revenus, user),
                    child: Center(
                      child: Text(
                        l10n.validerMethodeRetrait,
                        style: ClosetTextStyles.bouton.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.closetActionTexte,
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

  /// Moyens de la maquette, avec le numéro enregistré via `GET /sourcing/me`.
  List<MoyenRetrait> _moyensAffiches(ClosetL10n l10n) {
    final moyensRetrait = moyensRetraitPour(l10n);
    final profil = ref.watch(sourceurRepositoryProvider).profile;
    final numero = profil?.numeroPaiement ?? '';
    if (numero.isEmpty) return moyensRetrait;
    return [
      for (final moyen in moyensRetrait)
        MoyenRetrait(
          id: moyen.id,
          libelle: moyen.libelle,
          compte: moyen.id == _choisi ? numero : moyen.compte,
          icone: moyen.icone,
        ),
    ];
  }

  /// Ferme le panneau. Les retraits sont versés par ClosET : l'API mobile
  /// n'expose pas de déclenchement de virement.
  void _valider(
    BuildContext context,
    AsyncValue<RevenusSourceur> revenus,
    ClosetUser? user,
  ) {
    final l10n = ClosetL10n.of(context);
    Navigator.of(context).pop();
    toastInfo(ref, l10n.retraitsGeresTitre, l10n.virementsEmis);
  }

  /// Nombre de pièces effectivement en vente.
  static String _compteEnVente(List<PieceDeposee> pieces) {
    return pieces.where((p) => p.statut == StatutPiece.publiee).length.toString();
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
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: choisi ? ClosetColors.vert : ClosetColors.caseVide,
                    width: AppStroke.fin,
                  ),
                ),
                child: MarquePaiement(
                  id: moyen.id,
                  largeur: 45,
                  hauteur: 32,
                ),
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
