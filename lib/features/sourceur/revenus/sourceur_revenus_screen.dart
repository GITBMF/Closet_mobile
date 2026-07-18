import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_bottom_nav.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_header.dart';

/// Détail des revenus du sourceur (/sourceur/revenus) :
/// solde disponible, brut / commission / en attente, historique des ventes.
class SourceurRevenusScreen extends StatelessWidget {
  const SourceurRevenusScreen({
    super.key,
    this.solde = 0,
    this.brut = 0,
    this.commission = 0,
    this.enAttente = 0,
    this.moyenPaiement = 'MTN MoMo',
  });

  final int solde;
  final int brut;
  final int commission;
  final int enAttente;
  final String moyenPaiement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ClosetHeader(
              titre: 'Revenus',
              sousTitre: 'Atelier',
              wishlistCount: 2,
              panierCount: 2,
              notificationsCount: 6,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarteSolde(),
                    const SizedBox(height: 24),
                    _buildRecapitulatif(),
                    const SizedBox(height: 32),
                    _buildHistorique(),
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

  // ------------------------------------------------------------ Solde

  Widget _buildCarteSolde() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 32),
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
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: ClosetColors.dore),
              const SizedBox(width: 10),
              Text('SOLDE DISPONIBLE', style: ClosetTextStyles.labelChamp),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$solde FCFA',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero.copyWith(
              fontSize: 42,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Versé sur $moyenPaiement',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.corpsSurVert.copyWith(
              fontSize: 15,
              color: ClosetColors.texteSurVert.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          ClosetPrimaryButton(
            label: 'Demander un versement',
            dore: true,
            onPressed: solde > 0
                ? () {
                    // TODO: brancher la demande de versement (backend).
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ Récapitulatif

  Widget _buildRecapitulatif() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecapTile(
          icone: Icons.trending_up,
          label: 'BRUT',
          montant: '$brut FCFA',
        ),
        const SizedBox(width: 14),
        _RecapTile(
          icone: Icons.south_east,
          label: 'COMMISSION',
          montant: '− $commission FCFA',
          couleurIcone: ClosetColors.rougeBadge,
          fondPastille: const Color(0xFFF3DDD7),
        ),
        const SizedBox(width: 14),
        _RecapTile(
          icone: Icons.schedule,
          label: 'EN ATTENTE',
          montant: '$enAttente FCFA',
        ),
      ],
    );
  }

  // --------------------------------------------------------- Historique

  Widget _buildHistorique() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Text('HISTORIQUE DES VENTES', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Vos pièces adoptées',
          style: ClosetTextStyles.titreEcran.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 24),
        // TODO: afficher la liste des ventes quand le backend sera branché.
        Text(
          'Aucune vente pour le moment. Continuez à déposer vos plus '
          'belles pièces ✨',
          style: ClosetTextStyles.corps.copyWith(
            fontStyle: FontStyle.italic,
            color: ClosetColors.texteSecondaire,
          ),
        ),
      ],
    );
  }
}

class _RecapTile extends StatelessWidget {
  const _RecapTile({
    required this.icone,
    required this.label,
    required this.montant,
    this.couleurIcone = ClosetColors.noir,
    this.fondPastille = ClosetColors.ivoire,
  });

  final IconData icone;
  final String label;
  final String montant;
  final Color couleurIcone;
  final Color fondPastille;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: ClosetColors.creme,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ClosetColors.bordure),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: fondPastille,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 20, color: couleurIcone),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.labelEtape.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              montant,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.saisie.copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
