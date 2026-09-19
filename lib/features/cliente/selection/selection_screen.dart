import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../auth/auth_screen.dart';

/// Ma sélection — transcription de la maquette `16:3448`.
///
/// Liste des pièces mises de côté, champ de code privilège, récapitulatif
/// sous-total / livraison / total, puis bouton de finalisation.
class SelectionScreen extends ConsumerStatefulWidget {
  const SelectionScreen({super.key});

  @override
  ConsumerState<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends ConsumerState<SelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final pieces = ref.watch(cartListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: pieces.isEmpty
            ? ClosetListeVide(
                message: l10n.selectionVideMessage,
                action: () => context.go('/collections'),
                libelleAction: l10n.decouvrirCollections,
              )
            : Column(
                children: [
                  const SizedBox(height: AppSpacing.p16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.p20),
                    child: _BoutonFinaliser(),
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.p8,
                        bottom: AppSpacing.p32,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p20,
                          ),
                          child: Text(
                            pieces.length == 1
                                ? l10n.uneSeulePieceMiseDeCote
                                : l10n.nPiecesMisesDeCote(pieces.length),
                            style: ClosetTextStyles.citation.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.28,
                              color: context.closetSecondaire,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p16),
                        for (final piece in pieces) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.p20,
                            ),
                            child: _LignePiece(
                              article: piece,
                              onRetirer: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .removeArticle(piece.id);
                                toastActionPiece(
                                  ref,
                                  nom: piece.title,
                                  resultat: l10n.retireeDeSelection,
                                  succes: false,
                                );
                              },
                              onTap: () => context.push('/product/${piece.id}'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.p12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Ligne de pièce : carte blanche 350 × 146 cerclée d'or, visuel 107 × 127.
class _LignePiece extends StatelessWidget {
  const _LignePiece({
    required this.article,
    required this.onRetirer,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onRetirer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 146),
        padding: const EdgeInsets.all(AppSpacing.p8),
        decoration: BoxDecoration(
          color: context.closetCarte,
          border: Border.all(color: context.closetBordure, width: AppStroke.fin),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 107,
                height: 127,
                child: article.imageUrls.isEmpty
                    ? const ColoredBox(color: ClosetColors.gabaritImage)
                    : CachedNetworkImage(
                        imageUrl: article.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: ClosetColors.gabaritImage),
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: ClosetColors.gabaritImage),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    article.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.attribut.copyWith(
                      color: ClosetColors.fond400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.nomProduit.copyWith(
                      fontSize: 14,
                      letterSpacing: -0.28,
                      color: context.closetEncre,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p8),
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
                      article.libelleCondition(l10n),
                      style: ClosetTextStyles.attribut.copyWith(
                        color: ClosetColors.emeraude500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  Text(
                    formatPrixFcfa(article.price),
                    style: ClosetTextStyles.prixGrand.copyWith(
                      color: context.closetPrix,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: ClosetL10n.of(context).retirerDeSelection,
              child: GestureDetector(
                onTap: onRetirer,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: context.closetEncre,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CTA « Finaliser Ma sélection » : en haut de page pour un accès immédiat.
///
/// Redirige vers l'authentification si la cliente n'est pas connectée — le
/// paiement ne doit jamais démarrer sur une session anonyme.
class _BoutonFinaliser extends ConsumerWidget {
  const _BoutonFinaliser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectee = ref.watch<bool>(isAuthenticatedProvider);

    return SizedBox(
      key: ClosetTourKeys.finaliserKey,
      width: double.infinity,
      height: 44,
      child: Material(
        color: context.closetAction,
        borderRadius: BorderRadius.circular(AppRadius.cercle),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          onTap: () => context.push(connectee ? '/checkout' : '/auth'),
          child: Center(
            child: Text(
              ClosetL10n.of(context).finaliserMaSelection,
              style: ClosetTextStyles.bouton.copyWith(
                color: context.closetActionTexte,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
