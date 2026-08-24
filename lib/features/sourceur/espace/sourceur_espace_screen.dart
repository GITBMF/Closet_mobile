import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Mon espace sourceur � transcription de la maquette `31:109`.
///
/// Carte de solde vert profond (350 � 139), rang�e de quatre actions rapides,
/// liste d'acc�s, puis bouton � Confier une nouvelle pi�ce � ancr� en bas.
class SourceurEspaceScreen extends ConsumerWidget {
  const SourceurEspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenus = ref.watch(revenusSourceurProvider);
    final pieces = ref.watch(mesPiecesProvider);
    final verifie = ref.watch(sourceurRepositoryProvider).adhesion?.estValidee ==
        true;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Mon espace',
              onRetour: () => context.go('/espace'),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.person_outline,
                  label: 'Profil',
                  onTap: () => context.push('/espace/infos'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CarteSolde(
                      revenus: revenus,
                      verifie: verifie,
                      nbPieces: pieces.maybeWhen(
                        data: (l) =>
                            l.where((p) => p.statut == StatutPiece.publiee)
                                .length,
                        orElse: () => null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    _ActionsRapides(
                      onHistorique: () => context.push('/sourceur/revenus'),
                      onPlus: () => context.go('/sourceur/nouvelle'),
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    SourceurEntree(
                      premier: true,
                      icone: Icons.inventory_2_outlined,
                      label: 'Mes dépôts',
                      onTap: () => context.go('/sourceur/pieces'),
                    ),
                    SourceurEntree(
                      icone: Icons.person_outline,
                      label: 'Mes informations',
                      onTap: () => context.push('/espace/infos'),
                    ),
                    SourceurEntree(
                      icone: Icons.shield_outlined,
                      label: 'Polices et confidentialités',
                      onTap: () => context.push('/espace/confidentialite'),
                    ),
                    SourceurEntree(
                      icone: Icons.logout_rounded,
                      label: 'Logout',
                      onTap: () => context.push('/espace/deconnexion'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(39, 0, 39, AppSpacing.p16),
              child: SizedBox(
                height: 44,
                child: Material(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => context.go('/sourceur/nouvelle'),
                    child: Center(
                      child: Text(
                        '+ Confier une nouvelle pièce',
                        style: ClosetTextStyles.bouton.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.blanc,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de solde : 350 � 139, vert profond, rayon 8.
class _CarteSolde extends StatefulWidget {
  const _CarteSolde({
    required this.revenus,
    required this.nbPieces,
    required this.verifie,
  });

  final AsyncValue<RevenusSourceur> revenus;
  final int? nbPieces;
  final bool verifie;

  @override
  State<_CarteSolde> createState() => _CarteSoldeState();
}

class _CarteSoldeState extends State<_CarteSolde> {
  bool _masque = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 139),
      padding: const EdgeInsets.fromLTRB(23, 22, 23, AppSpacing.p16),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: widget.revenus.when(
        data: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Solde du compte',
                    style: ClosetTextStyles.actionPetite.copyWith(
                      letterSpacing: -0.20,
                      color: ClosetColors.fond300,
                    ),
                  ),
                ),
                if (widget.verifie)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p12,
                      vertical: AppSpacing.p4,
                    ),
                    decoration: BoxDecoration(
                      color: ClosetColors.emeraude100,
                      borderRadius: BorderRadius.circular(AppRadius.vignette),
                    ),
                    child: Text(
                      'Vérifié',
                      style: ClosetTextStyles.attribut.copyWith(
                        color: ClosetColors.emeraude500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _masque ? '••••••' : formatPrixFcfa(r.solde.toDouble()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.montantHero.copyWith(
                      color: ClosetColors.blanc,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _masque = !_masque),
                  child: Icon(
                    _masque
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: ClosetColors.fond300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.p16),
            Text(
              'Pièces en vente : ${(widget.nbPieces ?? 0).toString().padLeft(2, '0')} '
              'pièces',
              style: ClosetTextStyles.actionPetite.copyWith(
                letterSpacing: -0.20,
                color: ClosetColors.fond300,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'À reverser : ${_masque ? '••••••' : formatPrixFcfa(r.enAttente.toDouble())}',
              style: ClosetTextStyles.actionPetite.copyWith(
                letterSpacing: -0.20,
                color: ClosetColors.fond300,
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: ClosetColors.fond300,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Solde indisponible',
            style: ClosetTextStyles.corps.copyWith(color: ClosetColors.blanc),
          ),
        ),
      ),
    );
  }
}

/// Rang�e de quatre actions : 350 � 86, vert profond.
class _ActionsRapides extends StatelessWidget {
  const _ActionsRapides({
    required this.onHistorique,
    required this.onPlus,
  });

  final VoidCallback onHistorique;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Action(
            icone: Icons.history_rounded,
            label: 'Historique',
            onTap: onHistorique,
          ),
          _Action(
            icone: Icons.add,
            label: 'Plus',
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SourceurBoutonRond(icone: icone, label: label, onTap: onTap),
        const SizedBox(height: 3),
        Text(
          label,
          style: ClosetTextStyles.citation.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ClosetColors.blanc,
          ),
        ),
      ],
    );
  }
}
