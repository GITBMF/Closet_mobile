import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';

/// Catalogue en ligne d'un sourceur, atteint depuis la fiche produit.
///
/// Répond à la remarque « vendeur et traçabilité » : le nom du sourceur est
/// cliquable et mène à l'ensemble de ses pièces encore en vente.
class CatalogueSourceurScreen extends ConsumerWidget {
  const CatalogueSourceurScreen({
    super.key,
    required this.sourceurId,
    required this.nom,
  });

  final String sourceurId;

  /// Nom affiché en en-tête. Transmis par la fiche produit pour éviter un
  /// second appel réseau juste pour un libellé.
  final String nom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final pieces = ref.watch(catalogueSourceurProvider(sourceurId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ClosetPageHeader(
              titre: nom.trim().isEmpty ? l10n.catalogueTitre : nom.trim(),
              onRetour: () => context.pop(),
            ),
            Expanded(
              child: corpsAsync<List<Article>>(
                pieces,
                onRetry: () =>
                    ref.invalidate(catalogueSourceurProvider(sourceurId)),
                data: (liste) => liste.isEmpty
                    ? ClosetListeVide(
                        message: l10n.aucunePieceEnVenteSourceurMessage,
                        action: () => context.go('/collections'),
                        libelleAction: l10n.decouvrirCollections,
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.p20,
                          AppSpacing.p16,
                          AppSpacing.p20,
                          AppSpacing.p32,
                        ),
                        itemCount: liste.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.p12,
                          mainAxisSpacing: AppSpacing.p12,
                          childAspectRatio: PieceCard.ratioCarteGrille,
                        ),
                        itemBuilder: (context, i) {
                          final article = liste[i];
                          return ArticleCard(
                            article: article,
                            onTap: () =>
                                context.push('/product/${article.id}'),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
