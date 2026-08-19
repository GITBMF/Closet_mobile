import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../data/models/commande.dart';
import '../../../data/repositories/commande_repository.dart';
import 'mes_commandes_screen.dart';

/// Ouvre le détail de commande en feuille remontante — maquette overlay.
Future<void> afficherDetailCommande(BuildContext context, String numero) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, controller) => _FeuilleDetail(
        numero: numero,
        scrollController: controller,
      ),
    ),
  );
}

/// Route pleine page (lien profond) — même contenu que la feuille.
class DetailCommandeScreen extends StatelessWidget {
  const DetailCommandeScreen({super.key, required this.numero});

  final String numero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _EnTete(onRetour: () => context.pop()),
            Expanded(
              child: commande.when(
                data: (c) => c == null
                    ? EtatEcran.vide(
                        titre: 'Commande introuvable',
                        message: 'Cette commande n’apparaît plus dans votre historique.',
                        action: () => context.pop(),
                        libelleAction: 'Retour',
                      )
                    : _Corps(commande: c),
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(commandeProvider(numero)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeuilleDetail extends ConsumerWidget {
  const _FeuilleDetail({required this.numero, this.scrollController});

  final String numero;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(commandeProvider(numero));

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ClosetColors.beige,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.surface),
        ),
      ),
      child: commande.when(
        data: (c) => c == null
            ? const Center(child: Text('Commande introuvable'))
            : _Corps(
                commande: c,
                scrollController: scrollController,
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
      ),
    );
  }
}

class _Corps extends StatelessWidget {
  const _Corps({required this.commande, this.scrollController});

  final Commande commande;
  final ScrollController? scrollController;

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
                onTap: () => context.push(
                  '/espace/commandes/${commande.numero}/suivi',
                ),
                child: Center(
                  child: Text(
                    'Suivre ma commande',
                    style: ClosetTextStyles.bouton.copyWith(
                      color: ClosetColors.blanc,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p12),
        Center(
          child: TextButton(
            onPressed: () => context.go('/collections'),
            child: Text(
              'Passer d’autres commandes',
              style: ClosetTextStyles.bouton.copyWith(
                color: ClosetColors.vert,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EspaceBoutonFermer extends StatelessWidget {
  const EspaceBoutonFermer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
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

class _LignePiece extends StatelessWidget {
  const _LignePiece({required this.ligne});

  final LigneCommande ligne;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 78,
              height: 92,
              child: ligne.imageUrl == null
                  ? const ColoredBox(color: ClosetColors.gabaritImage)
                  : CachedNetworkImage(
                      imageUrl: ligne.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
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
                    color: ClosetColors.fond300,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ligne.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.nomProduit.copyWith(fontSize: 16),
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
                          ligne.etat.toUpperCase(),
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

class _CarteRecapitulatif extends StatelessWidget {
  const _CarteRecapitulatif({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p20),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.bloc),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOUS-TOTAL + LIVRAISON',
                  style: ClosetTextStyles.micro.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.p8),
                Text(
                  'TOTAL RÉGLÉ',
                  style: ClosetTextStyles.libelleFort.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.p12),
                Text(
                  'Les paiements sont chiffrés et sécurisés.',
                  style: ClosetTextStyles.micro.copyWith(
                    color: ClosetColors.neutre300,
                  ),
                ),
              ),
              Text(
                formatPrixFcfa(commande.totalCalcule),
                style: ClosetTextStyles.prixGrand.copyWith(
                  color: ClosetColors.blanc,
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
              color: ClosetColors.blanc,
            ),
          ),
        ],
      ),
    );
  }
}
