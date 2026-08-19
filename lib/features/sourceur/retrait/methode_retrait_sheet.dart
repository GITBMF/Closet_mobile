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
    this.logoAsset,
    this.libelleListe,
  });

  final String id;
  final String libelle;

  /// Numéro rattaché. Jamais affiché en entier hors de cet écran.
  final String compte;

  /// Logo de l'opérateur, si un fichier existe.
  final String? logoAsset;

  /// Libellé affiché dans la liste (ex. « VISA **** 4864 »).
  final String? libelleListe;

  String get libelleAffiche => libelleListe ?? libelle;
}

/// TODO(backend): les moyens de retrait doivent venir du profil sourceur.
const List<MoyenRetrait> moyensRetrait = [
  MoyenRetrait(
    id: 'orange',
    libelle: 'Orange Money',
    compte: '699000000',
    logoAsset: 'assets/orange.png',
  ),
  MoyenRetrait(
    id: 'mtn',
    libelle: 'MTN Mobile Money',
    compte: '677000000',
    logoAsset: 'assets/mtn.png',
  ),
  MoyenRetrait(
    id: 'visa',
    libelle: 'Carte Visa',
    compte: '4864',
    libelleListe: 'VISA **** 4864',
  ),
];

/// Ouvre le panneau « Méthode de retrait de fonds » — maquette `32:511`.
///
/// Overlay plein écran au-dessus de l'espace sourceur : carte blanche des
/// moyens, croix de fermeture, CTA vert ancré en bas. Valider lance le
/// tunnel de transaction en mode retrait.
Future<void> afficherMethodeRetrait(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => const _MethodeRetraitOverlay(),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

class _MethodeRetraitOverlay extends ConsumerStatefulWidget {
  const _MethodeRetraitOverlay();

  @override
  ConsumerState<_MethodeRetraitOverlay> createState() =>
      _MethodeRetraitOverlayState();
}

class _MethodeRetraitOverlayState
    extends ConsumerState<_MethodeRetraitOverlay> {
  String _choisi = 'visa';

  @override
  Widget build(BuildContext context) {
    final revenus = ref.watch(revenusSourceurProvider);
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ClosetColors.blanc,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
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
                width: double.infinity,
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

/// Ligne de moyen : logo, libellé, radio de sélection.
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
          padding: const EdgeInsets.symmetric(vertical: 14),
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
                  moyen.libelleAffiche,
                  style: ClosetTextStyles.libelle.copyWith(
                    color: ClosetColors.noir,
                  ),
                ),
              ),
              _Radio(choisi: choisi),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMoyen extends StatelessWidget {
  const _LogoMoyen({required this.moyen});

  final MoyenRetrait moyen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 42,
        height: 28,
        child: moyen.logoAsset != null
            ? Image.asset(moyen.logoAsset!, fit: BoxFit.cover)
            : const _LogoVisa(),
      ),
    );
  }
}

class _LogoVisa extends StatelessWidget {
  const _LogoVisa();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1A1F71),
      child: Center(
        child: Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.choisi});

  final bool choisi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: choisi ? ClosetColors.noir : ClosetColors.taupe100,
          width: 1.5,
        ),
      ),
      child: choisi
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: ClosetColors.noir,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
