import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Détail des revenus du sourceur (/sourceur/revenus)
class SourceurRevenusScreen extends ConsumerWidget {
  const SourceurRevenusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenusAsync = ref.watch(revenusSourceurProvider);

    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: revenusAsync.when(
                data: (revenus) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCarteSolde(revenus.solde, revenus.moyenPaiement),
                      const SizedBox(height: 24),
                      _buildRecapitulatif(
                          revenus.brut, revenus.commission, revenus.enAttente),
                      const SizedBox(height: 32),
                      _buildHistorique(revenus),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: ClosetColors.dore),
                ),
                error: (e, _) => Center(
                  child: Text('Erreur de chargement',
                      style: ClosetTextStyles.corps),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: ClosetColors.creme,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 13, color: ClosetColors.noir),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Revenus',
                  style: ClosetTextStyles.titreEcran.copyWith(fontSize: 16)),
              Text('Votre atelier', style: ClosetTextStyles.labelChamp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarteSolde(int solde, String moyenPaiement) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
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
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 15, color: ClosetColors.dore),
              const SizedBox(width: 8),
              Text('SOLDE DISPONIBLE', style: ClosetTextStyles.labelChamp),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$solde FCFA',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero.copyWith(
              fontSize: 30,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Versé sur $moyenPaiement',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.corpsSurVert.copyWith(
              fontSize: 14,
              color: ClosetColors.texteSurVert.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          ClosetPrimaryButton(
            label: 'Demander un versement',
            dore: true,
            onPressed: solde > 0 ? () {} : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapitulatif(int brut, int commission, int enAttente) {
    return IntrinsicHeight(
      child: Row(
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
            // Fond pastille commission — doux, conforme charte
            fondPastille: ClosetColors.fondsErreur,
          ),
          const SizedBox(width: 14),
          _RecapTile(
            icone: Icons.schedule,
            label: 'EN ATTENTE',
            montant: '$enAttente FCFA',
          ),
        ],
      ),
    );
  }

  Widget _buildHistorique(RevenusSourceur revenus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
            Text('HISTORIQUE DES VENTES', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 8),
        Text('Vos pièces adoptées',
            style: ClosetTextStyles.titreEcran.copyWith(fontSize: 18)),
        const SizedBox(height: 24),
        if (revenus.historique.isEmpty)
          Text(
            'Aucune vente pour le moment. Continuez à déposer vos plus '
            'belles pièces ✨',
            style: ClosetTextStyles.corps.copyWith(
              fontStyle: FontStyle.italic,
              color: ClosetColors.texteSecondaire,
            ),
          )
        else
          ...revenus.historique.map(
            (v) => _VenteTile(vente: v),
          ),
      ],
    );
  }
}

class _VenteTile extends StatelessWidget {
  final VenteSourceur vente;
  const _VenteTile({required this.vente});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClosetColors.bordure),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: ClosetColors.fondsSucces,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 17, color: ClosetColors.succes),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vente.nomPiece,
                    style: ClosetTextStyles.saisie.copyWith(fontSize: 14)),
                Text(
                  '${vente.date.day}/${vente.date.month}/${vente.date.year}',
                  style: ClosetTextStyles.corps.copyWith(
                      fontSize: 12, color: ClosetColors.texteSecondaire),
                ),
              ],
            ),
          ),
          Text(
            '${vente.montant.toInt()} FCFA',
            style: ClosetTextStyles.saisie.copyWith(
              fontSize: 15,
              color: ClosetColors.succes,
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: ClosetColors.creme,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ClosetColors.bordure),
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: fondPastille,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 17, color: couleurIcone),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.labelEtape.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              montant,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.saisie.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
