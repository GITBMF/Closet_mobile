import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/models/commande.dart';
import '../../../data/repositories/commande_repository.dart';
import '../../sourceur/widgets/sourceur_header.dart';
import 'mes_commandes_screen.dart';

/// Détails de la commande — transcription de la maquette `26:1262`.
///
/// Carte de suivi (numéro, statut, date, adresse), liste des pièces, puis
/// carte verte de récapitulatif portant le total à régler.
class DetailCommandeScreen extends ConsumerWidget {
  const DetailCommandeScreen({super.key, required this.numero});

  final String numero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(commandeProvider(numero));

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            _EnTete(onRetour: () => context.pop()),
            Expanded(
              child: commande.when(
                data: (c) => c == null
                    ? const Center(child: Text('Commande introuvable'))
                    : _Corps(commande: c),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: ClosetColors.dore),
                ),
                error: (e, _) => const Center(
                  child: Text('Erreur de chargement'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete({required this.onRetour});

  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ClosetColors.fond400,
            width: AppStroke.fin,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.p20,
          AppSpacing.p8,
          AppSpacing.p20,
          AppSpacing.p12,
        ),
        child: Row(
          children: [
            SourceurBoutonRond(
              icone: Icons.arrow_back_ios_new,
              label: 'Retour',
              onTap: onRetour,
            ),
            Expanded(
              child: Text(
                'Mes commandes',
                textAlign: TextAlign.center,
                style: ClosetTextStyles.libelle.copyWith(
                  fontSize: 18,
                  letterSpacing: 0.36,
                  color: ClosetColors.noir,
                ),
              ),
            ),
            const SizedBox(width: 42),
          ],
        ),
      ),
    );
  }
}

class _Corps extends StatelessWidget {
  const _Corps({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p24,
        AppSpacing.p20,
        AppSpacing.p32,
      ),
      children: [
        _CarteSuivi(commande: commande),
        const SizedBox(height: AppSpacing.p24),
        for (final ligne in commande.lignes) ...[
          _LignePiece(ligne: ligne),
          const SizedBox(height: AppSpacing.p12),
        ],
        const SizedBox(height: AppSpacing.p12),
        _CarteRecapitulatif(commande: commande),
        const SizedBox(height: AppSpacing.p24),
        Center(
          child: SizedBox(
            width: 312,
            height: 44,
            child: Material(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: () => context.go('/collections'),
                child: Center(
                  child: Text(
                    'Passer d’autres commandes',
                    style: ClosetTextStyles.bouton.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte de suivi : numéro, statut, dépôt et adresse de livraison.
class _CarteSuivi extends StatelessWidget {
  const _CarteSuivi({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMMANDE #${commande.numero}',
            style: ClosetTextStyles.accroche.copyWith(
              fontFamily: ClosetTextStyles.libelle.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.34,
              color: ClosetColors.vert,
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Row(
            children: [
              SizedBox(
                width: 104,
                child: Text(
                  'Statut',
                  style: ClosetTextStyles.saisie.copyWith(
                    color: ClosetColors.neutre700,
                  ),
                ),
              ),
              badgeStatutCommande(commande.statut),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          _LigneInfo(
            label: 'Déposé le',
            valeur: formatDateCommande(commande.dateDepot),
          ),
          if (commande.estimation != null) ...[
            const SizedBox(height: AppSpacing.p8),
            _LigneInfo(
              label: 'Estimation',
              valeur: formatDateCommande(commande.estimation!),
            ),
          ],
          if (commande.adresseLivraison != null) ...[
            const SizedBox(height: AppSpacing.p8),
            _LigneInfo(
              label: 'Livraison',
              valeur: commande.adresseLivraison!,
              couleurValeur: ClosetColors.neutre500,
            ),
          ],
        ],
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  const _LigneInfo({
    required this.label,
    required this.valeur,
    this.couleurValeur,
  });

  final String label;
  final String valeur;
  final Color? couleurValeur;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: ClosetTextStyles.corps.copyWith(
              color: ClosetColors.neutre700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valeur,
            style: ClosetTextStyles.corps.copyWith(
              color: couleurValeur ?? ClosetColors.neutre900,
            ),
          ),
        ),
      ],
    );
  }
}

/// Pièce commandée : visuel 78, maison dorée, nom Cormorant, prix EB Garamond.
class _LignePiece extends StatelessWidget {
  const _LignePiece({required this.ligne});

  final LigneCommande ligne;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              width: 78,
              height: 92,
              child: ligne.imageUrl == null
                  ? const ColoredBox(color: Color(0xFFD9D9D9))
                  : CachedNetworkImage(
                      imageUrl: ligne.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: Color(0xFFD9D9D9)),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: Color(0xFFD9D9D9)),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ligne.maison.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.attribut.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    color: ClosetColors.fond300,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  ligne.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.citation.copyWith(fontSize: 19),
                ),
                const SizedBox(height: AppSpacing.p8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatPrixFcfa(ligne.prix),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClosetTextStyles.prix.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.34,
                          color: ClosetColors.vert,
                        ),
                      ),
                    ),
                    if (ligne.etat.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ClosetColors.emeraude100,
                          borderRadius:
                              BorderRadius.circular(AppRadius.vignette),
                        ),
                        child: Text(
                          ligne.etat,
                          style: ClosetTextStyles.attribut.copyWith(
                            color: ClosetColors.emeraude500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte verte du récapitulatif : sous-total + livraison, puis total.
class _CarteRecapitulatif extends StatelessWidget {
  const _CarteRecapitulatif({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p20),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sous-total + livraison',
            style: ClosetTextStyles.sousTitre.copyWith(
              fontSize: 16,
              color: ClosetColors.neutre300,
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Total à régler',
                  style: ClosetTextStyles.corpsMedium.copyWith(
                    color: ClosetColors.neutre300,
                  ),
                ),
              ),
              Text(
                formatPrixFcfa(commande.total),
                style: ClosetTextStyles.prixGrand.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p16),
          Text(
            'Paiement chiffré. Votre pièce est réservée pendant 15 minutes.',
            style: ClosetTextStyles.microLegende.copyWith(
              fontWeight: FontWeight.w300,
              letterSpacing: 0.14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
