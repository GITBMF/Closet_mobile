import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../../data/services/auth_storage_service.dart';
import '../widgets/sourceur_header.dart';

/// Mon espace sourceur — transcription de la maquette `31:109`.
///
/// Carte de solde vert profond (350 × 139), rangée de quatre actions rapides,
/// liste d'accès, puis bouton « Confier une nouvelle pièce » ancré en bas.
class SourceurEspaceScreen extends ConsumerWidget {
  const SourceurEspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenus = ref.watch(revenusSourceurProvider);
    final pieces = ref.watch(mesPiecesProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Mon espace',
              onRetour: () => context.go('/espace'),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.tune,
                  label: 'Réglages',
                  onTap: () => context.push('/espace/confidentialite'),
                ),
                const SizedBox(width: AppSpacing.gapListe),
                SourceurBoutonRond(
                  icone: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/espace/alertes'),
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
                      nbPieces: pieces.maybeWhen(
                        data: (l) =>
                            l.where((p) => p.statut == StatutPiece.publiee)
                                .length,
                        orElse: () => null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    _ActionsRapides(
                      onRetrait: () => context.push('/sourceur/revenus'),
                      onHistorique: () => context.push('/sourceur/revenus'),
                      onMoyens: () => context.push('/espace/paiements'),
                      onPlus: () => context.push('/sourceur/pieces'),
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
                      onTap: () => _deconnecter(context, ref),
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
                          color: Colors.white,
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

  /// Déconnexion : purge du stockage avant l'état mémoire, puis remplacement
  /// de la pile — cf. `EspaceScreen`, même contrainte de sécurité.
  Future<void> _deconnecter(BuildContext context, WidgetRef ref) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ClosetColors.creme,
        title: Text('Se déconnecter', style: ClosetTextStyles.titreSection),
        content: Text(
          'Vous devrez saisir à nouveau vos identifiants.',
          style: ClosetTextStyles.citation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler', style: ClosetTextStyles.bouton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Se déconnecter',
              style: ClosetTextStyles.bouton.copyWith(
                color: ClosetColors.erreurCouture,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    await AuthStorageService.clearAuthData();
    ref.read(currentUserProvider.notifier).state = null;
    if (context.mounted) context.go('/auth');
  }
}

/// Carte de solde : 350 × 139, vert profond, rayon 8.
class _CarteSolde extends StatelessWidget {
  const _CarteSolde({required this.revenus, required this.nbPieces});

  final AsyncValue<RevenusSourceur> revenus;
  final int? nbPieces;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 139,
      padding: const EdgeInsets.fromLTRB(23, 22, 23, AppSpacing.p16),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: revenus.when(
        data: (r) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'solde du compte',
                    style: ClosetTextStyles.actionPetite.copyWith(
                      letterSpacing: -0.20,
                      color: ClosetColors.fond300,
                    ),
                  ),
                ),
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
                    'vérifié',
                    style: ClosetTextStyles.attribut.copyWith(
                      color: ClosetColors.emeraude500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              formatPrixFcfa(r.solde.toDouble()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ClosetTextStyles.montantHero.copyWith(
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              'pièces en vente : ${(nbPieces ?? 0).toString().padLeft(2, '0')} '
              'pièces',
              style: ClosetTextStyles.actionPetite.copyWith(
                letterSpacing: -0.20,
                color: ClosetColors.fond300,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'à reverser : ${formatPrixFcfa(r.enAttente.toDouble())}',
              style: ClosetTextStyles.actionPetite.copyWith(
                letterSpacing: -0.20,
                color: ClosetColors.fond300,
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.fond300),
        ),
        error: (e, _) => Center(
          child: Text(
            'Solde indisponible',
            style: ClosetTextStyles.corps.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Rangée de quatre actions : 350 × 86, vert profond.
class _ActionsRapides extends StatelessWidget {
  const _ActionsRapides({
    required this.onRetrait,
    required this.onHistorique,
    required this.onMoyens,
    required this.onPlus,
  });

  final VoidCallback onRetrait;
  final VoidCallback onHistorique;
  final VoidCallback onMoyens;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Action(
            icone: Icons.account_balance_wallet_outlined,
            label: 'Retrait',
            onTap: onRetrait,
          ),
          _Action(
            icone: Icons.history_rounded,
            label: 'Historique',
            onTap: onHistorique,
          ),
          _Action(
            icone: Icons.credit_card_outlined,
            label: 'Moyens',
            onTap: onMoyens,
          ),
          _Action(
            icone: Icons.grid_view_rounded,
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
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
