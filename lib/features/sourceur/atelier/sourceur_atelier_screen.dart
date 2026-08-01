import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Tableau de bord de l'atelier du sourceur (/sourceur)
class SourceurAtelierScreen extends ConsumerWidget {
  const SourceurAtelierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch<SourceurRepository>(sourceurRepositoryProvider);
    final profile = repo.profile;
    final nomAtelier = profile?.nomAtelier ?? 'Mon Atelier';
    final ville = profile?.ville ?? 'Yaoundé';
    final depuis = profile?.depuis ?? 'Juillet 2026';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, nomAtelier, theme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.p20, AppSpacing.p8, AppSpacing.p20, AppSpacing.p32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarteIdentite(nomAtelier, ville, depuis, 0, 0, 0),
                    const SizedBox(height: AppSpacing.p24),
                    _buildCarteRevenus(context, 0, 0, 0, theme),
                    const SizedBox(height: AppSpacing.p24),
                    _buildActionsRapides(context, 0),
                    const SizedBox(height: AppSpacing.p32),
                    _buildActivite(context, 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String nomAtelier, ThemeData theme) {
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: const Border(bottom: BorderSide(color: ClosetColors.ligne)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.p20, AppSpacing.p16, AppSpacing.p20, AppSpacing.p12),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Retour',
              child: Tooltip(
                message: 'Retour',
                child: GestureDetector(
                  onTap: () => context.go('/espace'),
                  child: Container(
                    width: AppSpacing.minTouchTarget,
                    height: AppSpacing.minTouchTarget,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 13, color: cs.onSurface),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.p12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atelier',
                    style: ClosetTextStyles.titreEcran.copyWith(fontSize: 16, color: cs.onSurface)),
                Text(nomAtelier, style: ClosetTextStyles.labelChamp),
              ],
            ),
            const Spacer(),
            const Icon(Icons.auto_awesome, size: 16, color: ClosetColors.dore),
          ],
        ),
      ),
    );
  }

  Widget _buildCarteIdentite(
    String nomAtelier,
    String ville,
    String depuis,
    int depots,
    int publiees,
    int vendues,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
      decoration: const BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 13, color: ClosetColors.dore),
              const SizedBox(width: 8),
              Text('CERCLE DES SOURCEURS',
                  style: ClosetTextStyles.labelChamp),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nomAtelier,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero,
          ),
          const SizedBox(height: 10),
          Text(
            '${ville.toUpperCase()} · DEPUIS ${depuis.toUpperCase()}',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.labelChamp,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _StatTile(valeur: depots, label: 'DÉPÔTS'),
              const SizedBox(width: 12),
              _StatTile(valeur: publiees, label: 'PUBLIÉES'),
              const SizedBox(width: 12),
              _StatTile(valeur: vendues, label: 'VENDUES'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarteRevenus(
      BuildContext context, int revenusNet, int revenusBrut, int revenusEnAttente, ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClosetColors.bordure),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: ClosetColors.dore),
                const SizedBox(width: AppSpacing.p8),
                Text('REVENUS', style: ClosetTextStyles.labelChamp),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$revenusNet FCFA',
                        style: ClosetTextStyles.titreEcran.copyWith(
                          fontSize: 28,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Net après commission ClosET (25%)',
                        style: ClosetTextStyles.corps.copyWith(
                          fontSize: 13,
                          color: ClosetColors.texteSecondaire,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.p12),
                Semantics(
                  button: true,
                  label: 'Voir mes revenus',
                  child: Material(
                    color: ClosetColors.dore,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go('/sourceur/revenus'),
                      child: const SizedBox(
                        width: AppSpacing.minTouchTarget,
                        height: AppSpacing.minTouchTarget,
                        child: Icon(Icons.chevron_right,
                            size: 22, color: ClosetColors.noir),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.p20),
            Row(
              children: [
                _RevenuTile(label: 'EN ATTENTE', montant: revenusEnAttente),
                const SizedBox(width: AppSpacing.p16),
                _RevenuTile(label: 'BRUT TOTAL', montant: revenusBrut),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsRapides(BuildContext context, int depots) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ActionCard(
              fond: ClosetColors.dore,
              bordure: ClosetColors.doreEncre,
              pastille: ClosetColors.noir,
              icone: Icons.add,
              couleurIcone: ClosetColors.dore,
              titre: 'Déposer',
              label: 'NOUVELLE PIÈCE',
              onTap: () => context.go('/sourceur/nouvelle'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionCard(
              fond: ClosetColors.creme,
              bordure: ClosetColors.bordure,
              pastille: ClosetColors.vert,
              icone: Icons.inventory_2_outlined,
              couleurIcone: ClosetColors.texteSurVert,
              titre: 'Mes dépôts',
              label: '$depots PIÈCE${depots == 1 ? '' : 'S'}',
              onTap: () => context.go('/sourceur/pieces'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivite(BuildContext context, int depots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
            Text('ACTIVITÉ', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 8),
        Text('Derniers dépôts',
            style: ClosetTextStyles.titreEcran.copyWith(fontSize: 18)),
        const SizedBox(height: 18),
        if (depots == 0) _buildAucunDepot(context),
      ],
    );
  }

  Widget _buildAucunDepot(BuildContext context) {
    // État vide transformé en suggestion active (chantier UX Agentive)
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClosetColors.ligne, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p24, vertical: AppSpacing.p32,
        ),
        child: Column(
          children: [
            // Icône éditoriale
            DecoratedBox(
              decoration: BoxDecoration(
                color: ClosetColors.dore.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.p16),
                child: Icon(Icons.checkroom_outlined, size: 32, color: ClosetColors.dore),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            Text(
              'Pas encore de pièce déposée',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreEcran.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.p8),
            Text(
              'Votre première pièce est à portée de main. '
              'Les sourceurs actifs reçoivent leurs premières ventes sous 30 jours.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corps.copyWith(
                fontSize: 13,
                color: ClosetColors.texteSecondaire,
              ),
            ),
            const SizedBox(height: AppSpacing.p24),
            ClosetPrimaryButton(
              label: 'Déposer ma première pièce',
              onPressed: () => context.go('/sourceur/nouvelle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.valeur, required this.label});

  final int valeur;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ClosetColors.texteSurVert.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$valeur',
              style: ClosetTextStyles.numeroEtape.copyWith(
                fontSize: 20,
                color: ClosetColors.dore,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: ClosetTextStyles.navigation.copyWith(
                color: ClosetColors.texteSurVert,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenuTile extends StatelessWidget {
  const _RevenuTile({required this.label, required this.montant});

  final String label;
  final int montant;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ClosetColors.ivoire,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ClosetTextStyles.labelEtape.copyWith(
                fontSize: 10,
                color: ClosetColors.texteSecondaire,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$montant FCFA',
              style: ClosetTextStyles.saisie.copyWith(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.fond,
    required this.bordure,
    required this.pastille,
    required this.icone,
    required this.couleurIcone,
    required this.titre,
    required this.label,
    required this.onTap,
  });

  final Color fond;
  final Color bordure;
  final Color pastille;
  final IconData icone;
  final Color couleurIcone;
  final String titre;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fond,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: bordure),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: pastille,
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, size: 18, color: couleurIcone),
              ),
              const SizedBox(height: 14),
              Text(
                titre,
                style: ClosetTextStyles.titreEcran.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: ClosetTextStyles.labelEtape.copyWith(
                  fontSize: 10,
                  color: ClosetColors.noir.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
