import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/closet_sections.dart';
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
    final pieces = ref.watch(cartListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: pieces.isEmpty
            ? ClosetListeVide(
                message: 'Aucune pièce n’a été mise de côté.',
                action: () => context.go('/collections'),
                libelleAction: 'Découvrir les collections',
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.p32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.p12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.p20),
                      child: ClosetTitreEcran('Ma sélection'),
                    ),
                    const SizedBox(height: AppSpacing.p16),
                    const _BoutonFinaliser(),
                    const SizedBox(height: AppSpacing.p20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p24,
                      ),
                      child: Text(
                        pieces.length == 1
                            ? '1 pièce unique mise de côté pour vous.'
                            : '${pieces.length} pièces uniques mises de côté '
                                'pour vous.',
                        style: ClosetTextStyles.citation.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.28,
                          color: ClosetColors.neutre700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
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
                              resultat: 'a été retirée de votre sélection.',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 146),
        padding: const EdgeInsets.all(AppSpacing.p8),
        decoration: BoxDecoration(
          color: ClosetColors.blanc,
          border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
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
                      article.condition,
                      style: ClosetTextStyles.attribut.copyWith(
                        color: ClosetColors.emeraude500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p12),
                  Text(
                    formatPrixFcfa(article.price),
                    style: ClosetTextStyles.prixGrand.copyWith(
                      color: ClosetColors.vert,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: 'Retirer de ma sélection',
              child: GestureDetector(
                onTap: onRetirer,
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: ClosetColors.noirPur,
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

    return Center(
      child: SizedBox(
        width: 312,
        height: 44,
        child: Material(
          color: ClosetColors.vert,
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.cercle),
            onTap: () => context.push(connectee ? '/checkout' : '/auth'),
            child: Center(
              child: Text(
                'Finaliser ma sélection',
                style: ClosetTextStyles.bouton.copyWith(
                  color: ClosetColors.blanc,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
