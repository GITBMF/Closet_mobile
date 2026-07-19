import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/bordure_pointillee.dart';
import '../../../core/widgets/closet_bottom_nav.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_header.dart';
import '../nouvelle/sourceur_nouvelle_piece_screen.dart';
import '../pieces/sourceur_pieces_screen.dart';
import '../revenus/sourceur_revenus_screen.dart';

/// Tableau de bord de l'atelier du sourceur (/sourceur) :
/// carte identité, revenus, actions rapides et derniers dépôts.
class SourceurAtelierScreen extends StatelessWidget {
  const SourceurAtelierScreen({
    super.key,
    this.nomAtelier = 'lul',
    this.ville = 'Yaoundé',
    this.depuis = 'Juillet 2026',
    this.depots = 0,
    this.publiees = 0,
    this.vendues = 0,
    this.revenusNet = 0,
    this.revenusEnAttente = 0,
    this.revenusBrut = 0,
  });

  final String nomAtelier;
  final String ville;
  final String depuis;
  final int depots;
  final int publiees;
  final int vendues;
  final int revenusNet;
  final int revenusEnAttente;
  final int revenusBrut;

  void _ouvrirDepot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SourceurNouvellePieceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ClosetHeader(
              titre: 'Atelier',
              sousTitre: nomAtelier,
              wishlistCount: 2,
              panierCount: 2,
              notificationsCount: 3,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarteIdentite(),
                    const SizedBox(height: 24),
                    _buildCarteRevenus(context),
                    const SizedBox(height: 24),
                    _buildActionsRapides(context),
                    const SizedBox(height: 32),
                    _buildActivite(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClosetBottomNav(indexActif: -1, onTap: (_) {}),
    );
  }

  // ---------------------------------------------------------- Carte identité

  Widget _buildCarteIdentite() {
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
              const Icon(Icons.auto_awesome,
                  size: 15, color: ClosetColors.dore),
              const SizedBox(width: 8),
              Text(
                'CERCLE DES SOURCEURS',
                style: ClosetTextStyles.labelChamp,
              ),
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

  // ------------------------------------------------------------ Revenus

  Widget _buildCarteRevenus(BuildContext context) {
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
                      style: ClosetTextStyles.titreEcran.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Net après commission Clos ET (25%)',
                      style: ClosetTextStyles.corps.copyWith(
                        fontSize: 15,
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
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SourceurRevenusScreen(
                        solde: revenusNet,
                        brut: revenusBrut,
                        commission: revenusBrut - revenusNet,
                        enAttente: revenusEnAttente,
                      ),
                    ),
                  ),
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

  // ------------------------------------------------------ Actions rapides

  Widget _buildActionsRapides(BuildContext context) {
    // IntrinsicHeight égalise la hauteur des deux cartes sans imposer de
    // contrainte infinie (on est dans un scroll à hauteur non bornée).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ActionCard(
              fond: ClosetColors.dore,
              bordure: const Color(0xFFA07E35),
              pastille: ClosetColors.noir,
              icone: Icons.add,
              couleurIcone: ClosetColors.dore,
              titre: 'Déposer',
              label: 'NOUVELLE PIÈCE',
              onTap: () => _ouvrirDepot(context),
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
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SourceurPiecesScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ Activité

  Widget _buildActivite(BuildContext context) {
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
        Text(
          'Derniers dépôts',
          style: ClosetTextStyles.titreEcran.copyWith(fontSize: 24),
        ),
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
              onPressed: () => _ouvrirDepot(context),
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

