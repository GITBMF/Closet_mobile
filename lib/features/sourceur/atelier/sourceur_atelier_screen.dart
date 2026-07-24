import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/bordure_pointillee.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Tableau de bord de l'atelier du sourceur (/sourceur)
class SourceurAtelierScreen extends ConsumerWidget {
  const SourceurAtelierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sourceurRepositoryProvider);
    final profile = repo.profile;
    final nomAtelier = profile?.nomAtelier ?? 'Mon Atelier';
    final ville = profile?.ville ?? 'Yaoundé';
    final depuis = profile?.depuis ?? 'Juillet 2026';

    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, nomAtelier),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarteIdentite(nomAtelier, ville, depuis, 0, 0, 0),
                    const SizedBox(height: 24),
                    _buildCarteRevenus(context, 0, 0, 0),
                    const SizedBox(height: 24),
                    _buildActionsRapides(context, 0),
                    const SizedBox(height: 32),
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

  Widget _buildTopBar(BuildContext context, String nomAtelier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: ClosetColors.ivoire,
        border: Border(bottom: BorderSide(color: ClosetColors.ligne)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: ClosetColors.creme,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 14, color: ClosetColors.noir),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atelier',
                  style: ClosetTextStyles.titreEcran.copyWith(fontSize: 18)),
              Text(nomAtelier, style: ClosetTextStyles.labelChamp),
            ],
          ),
          const Spacer(),
          const Icon(Icons.auto_awesome, size: 18, color: ClosetColors.dore),
        ],
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
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
      decoration: const BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(110),
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 15, color: ClosetColors.dore),
              const SizedBox(width: 8),
              Text('CERCLE DES SOURCEURS',
                  style: ClosetTextStyles.labelChamp),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nomAtelier,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 10),
          Text(
            '${ville.toUpperCase()} · DEPUIS ${depuis.toUpperCase()}',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.labelChamp,
          ),
          const SizedBox(height: 26),
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
      BuildContext context, int revenusNet, int revenusBrut, int revenusEnAttente) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ClosetColors.bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 20, color: ClosetColors.dore),
              const SizedBox(width: 10),
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
                      style:
                          ClosetTextStyles.titreEcran.copyWith(fontSize: 36),
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
              const SizedBox(width: 12),
              Material(
                color: ClosetColors.dore,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.go('/sourceur/revenus'),
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.chevron_right,
                        size: 30, color: ClosetColors.noir),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _RevenuTile(label: 'EN ATTENTE', montant: revenusEnAttente),
              const SizedBox(width: 14),
              _RevenuTile(label: 'BRUT TOTAL', montant: revenusBrut),
            ],
          ),
        ],
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
            const Icon(Icons.trending_up, size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Text('ACTIVITÉ', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 8),
        Text('Derniers dépôts',
            style: ClosetTextStyles.titreEcran.copyWith(fontSize: 24)),
        const SizedBox(height: 18),
        if (depots == 0) _buildAucunDepot(context),
      ],
    );
  }

  Widget _buildAucunDepot(BuildContext context) {
    return BordurePointillee(
      couleur: ClosetColors.dore.withValues(alpha: 0.5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.photo_camera_outlined,
                size: 40, color: ClosetColors.texteSecondaire),
            const SizedBox(height: 18),
            Text(
              'Aucune pièce déposée pour le moment.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corps.copyWith(
                fontStyle: FontStyle.italic,
                color: ClosetColors.texteSecondaire,
              ),
            ),
            const SizedBox(height: 24),
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: ClosetColors.texteSurVert.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              '$valeur',
              style: ClosetTextStyles.numeroEtape.copyWith(
                fontSize: 24,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ClosetColors.ivoire,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ClosetTextStyles.labelEtape.copyWith(
                fontSize: 11,
                color: ClosetColors.texteSecondaire,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$montant FCFA',
              style: ClosetTextStyles.saisie.copyWith(fontSize: 20),
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
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: bordure),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: pastille,
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, size: 22, color: couleurIcone),
              ),
              const SizedBox(height: 18),
              Text(
                titre,
                style: ClosetTextStyles.titreEcran.copyWith(fontSize: 23),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: ClosetTextStyles.labelEtape.copyWith(
                  fontSize: 11,
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
