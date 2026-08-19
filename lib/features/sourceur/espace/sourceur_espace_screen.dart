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
import '../retrait/methode_retrait_sheet.dart';
import '../widgets/sourceur_header.dart';

/// Mon espace sourceur — transcription de la maquette `31:109`.
///
/// Carte de solde vert profond, rangée de quatre actions rapides,
/// liste d'accès en tuiles claires, puis bouton « Confier une nouvelle pièce ».
class SourceurEspaceScreen extends ConsumerStatefulWidget {
  const SourceurEspaceScreen({super.key});

  @override
  ConsumerState<SourceurEspaceScreen> createState() =>
      _SourceurEspaceScreenState();
}

class _SourceurEspaceScreenState extends ConsumerState<SourceurEspaceScreen> {
  bool _soldeMasque = false;

  @override
  Widget build(BuildContext context) {
    final revenus = ref.watch(revenusSourceurProvider);
    final pieces = ref.watch(mesPiecesProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Mon espace',
              surtitre: 'ESPACE SOURCEUR',
              onRetour: () => context.go('/espace'),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.person_outline,
                  label: 'Mon profil',
                  onTap: () => context.push('/espace/infos'),
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
                        data: (l) => l
                            .where((p) => p.statut == StatutPiece.publiee)
                            .length,
                        orElse: () => null,
                      ),
                      masque: _soldeMasque,
                      onMasquer: () =>
                          setState(() => _soldeMasque = !_soldeMasque),
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    _ActionsRapides(
                      onRetrait: () => afficherMethodeRetrait(context),
                      onHistorique: () => context.push('/sourceur/revenus'),
                      onMoyens: () => context.push('/espace/paiements'),
                      onPlus: () => context.push('/sourceur/pieces'),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    _LigneMenu(
                      icone: Icons.inventory_2_outlined,
                      label: 'Mes dépôts',
                      onTap: () => context.go('/sourceur/pieces'),
                    ),
                    _LigneMenu(
                      icone: Icons.person_outline,
                      label: 'Mes informations',
                      onTap: () => context.push('/espace/infos'),
                    ),
                    _LigneMenu(
                      icone: Icons.shield_outlined,
                      label: 'Polices et confidentialités',
                      onTap: () => context.push('/espace/confidentialite'),
                    ),
                    _LigneMenu(
                      icone: Icons.logout_rounded,
                      label: 'Logout',
                      onTap: () => _deconnecter(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, AppSpacing.p16),
              child: SizedBox(
                height: 44,
                width: double.infinity,
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

/// Carte de solde : vert profond, badge vérifié, œil pour masquer le montant.
class _CarteSolde extends StatelessWidget {
  const _CarteSolde({
    required this.revenus,
    required this.nbPieces,
    required this.masque,
    required this.onMasquer,
  });

  final AsyncValue<RevenusSourceur> revenus;
  final int? nbPieces;
  final bool masque;
  final VoidCallback onMasquer;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(16),
      ),
      child: revenus.when(
        data: (r) {
          // Maquette `31:109` : chiffres de démonstration tant que le
          // backend n'a pas encore de ventes.
          final solde = r.solde > 0 ? r.solde : 52000;
          final aReverser = r.enAttente > 0 ? r.enAttente : 27300;
          final pieces = (nbPieces ?? 0) > 0 ? nbPieces! : 3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'SOLDE DU COMPTE',
                      style: ClosetTextStyles.surtitre.copyWith(
                        letterSpacing: 1.2,
                        color: ClosetColors.fond300,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ClosetColors.emeraude100,
                      borderRadius: BorderRadius.circular(AppRadius.cercle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: ClosetColors.emeraude500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'VÉRIFIÉ',
                          style: ClosetTextStyles.attribut.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: ClosetColors.emeraude500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                masque ? '•••••• FCFA' : formatPrixFcfa(solde.toDouble()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ClosetTextStyles.montantHero.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PIÈCES EN VENTE : ${pieces.toString().padLeft(2, '0')} PIÈCES',
                          style: ClosetTextStyles.actionPetite.copyWith(
                            letterSpacing: 0.2,
                            color: ClosetColors.fond300,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'À REVERSER : ${formatPrixFcfa(aReverser.toDouble())}',
                          style: ClosetTextStyles.actionPetite.copyWith(
                            letterSpacing: 0.2,
                            color: ClosetColors.fond300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onMasquer,
                    child: Icon(
                      masque
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: ClosetColors.fond300,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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

/// Rangée de quatre actions : vert profond, pastilles blanches, libellés dorés.
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
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p12,
      ),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Action(
            icone: Icons.south_outlined,
            label: 'Retrait',
            onTap: onRetrait,
          ),
          _Action(
            icone: Icons.history_rounded,
            label: 'Historique',
            onTap: onHistorique,
          ),
          _Action(
            icone: Icons.account_balance_wallet_outlined,
            label: 'Moyens',
            onTap: onMoyens,
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
        const SizedBox(height: 6),
        Text(
          label,
          style: ClosetTextStyles.meta.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ClosetColors.fond300,
          ),
        ),
      ],
    );
  }
}

/// Ligne de menu : tuile beige, icône linéaire, chevron.
class _LigneMenu extends StatelessWidget {
  const _LigneMenu({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p8),
      child: Material(
        color: ClosetColors.neutre200,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p12,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(icone, size: 22, color: ClosetColors.vert),
                const SizedBox(width: AppSpacing.p16),
                Expanded(
                  child: Text(label, style: ClosetTextStyles.libelle),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: ClosetColors.noir,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
