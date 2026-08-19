import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../transaction/transaction_models.dart';

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

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                  tooltip: 'Fermer',
                ),
              ),
              const SizedBox(height: AppSpacing.p8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Methode de retrait de fonds',
                      textAlign: TextAlign.center,
                      style: ClosetTextStyles.libelleFort.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    for (var i = 0; i < moyensRetrait.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: ClosetColors.caseVide,
                        ),
                      _LigneMoyen(
                        moyen: moyensRetrait[i],
                        choisi: moyensRetrait[i].id == _choisi,
                        onTap: () =>
                            setState(() => _choisi = moyensRetrait[i].id),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
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
                          color: Colors.white,
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

  /// Ferme le panneau puis ouvre le tunnel de transaction en mode retrait.
  void _valider(
    BuildContext context,
    AsyncValue<RevenusSourceur> revenus,
    ClosetUser? user,
  ) {
    // Maquette : 27 300 FCFA tant que le backend n'a pas de solde à reverser.
    final montant = revenus.maybeWhen(
      data: (r) => r.enAttente > 0 ? r.enAttente.toDouble() : 27300.0,
      orElse: () => 27300.0,
    );

    MoyenRetrait moyen = moyensRetrait.last;
    for (final m in moyensRetrait) {
      if (m.id == _choisi) moyen = m;
    }

    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(
      '/transaction',
      extra: DemandeTransaction(
        type: TypeOperation.retrait,
        montant: montant,
        moyen: moyen.libelle,
        compte: moyen.compte,
        beneficiaire: user == null
            ? 'Sourceur ClosET'
            : '${user.firstName} ${user.lastName}'.trim(),
      ),
    );
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
              _LogoMoyen(moyen: moyen),
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
