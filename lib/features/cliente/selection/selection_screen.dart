import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../auth/auth_screen.dart';

/// Frais de livraison — valeur de la maquette (`16:3448`).
///
/// TODO(backend): les frais doivent venir du serveur, ils dépendent de la
/// zone de livraison. Constante figée tant que l'endpoint n'existe pas.
const double fraisLivraison = 3500;

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
  final _codePrivilege = TextEditingController();

  @override
  void dispose() {
    _codePrivilege.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pieces = ref.watch(cartListProvider);
    final sousTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: const ClosetAppBar(),
      body: pieces.isEmpty
          ? const _SelectionVide()
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
                  const SizedBox(height: AppSpacing.p20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
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
                        onRetirer: () => ref
                            .read(cartProvider.notifier)
                            .removeArticle(piece.id),
                        onTap: () => context.push('/product/${piece.id}'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                  ],
                  const SizedBox(height: AppSpacing.p8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p20,
                    ),
                    child: _CodePrivilege(controller: _codePrivilege),
                  ),
                  const SizedBox(height: AppSpacing.p24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p20,
                    ),
                    child: _Recapitulatif(
                      sousTotal: sousTotal,
                      livraison: fraisLivraison,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p24),
                  const _BoutonFinaliser(),
                ],
              ),
            ),
    );
  }
}

class _SelectionVide extends StatelessWidget {
  const _SelectionVide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size: 48,
              color: ClosetColors.fond300,
            ),
            const SizedBox(height: AppSpacing.p20),
            Text(
              'Votre sélection est vide',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              'Parcourez le dressing et mettez de côté les pièces qui vous '
              'ressemblent.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.citation.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
            const SizedBox(height: AppSpacing.p24),
            SizedBox(
              width: 240,
              height: 44,
              child: Material(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  onTap: () => context.go('/collections'),
                  child: Center(
                    child: Text(
                      'Découvrir les collections',
                      style: ClosetTextStyles.bouton.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
          color: Colors.white,
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
                    ? const ColoredBox(color: Color(0xFFD9D9D9))
                    : CachedNetworkImage(
                        imageUrl: article.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
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
                  child: Icon(Icons.close, size: 15, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte « Code privilège » : champ 189 × 38 et bouton vert 114 × 38.
class _CodePrivilege extends StatelessWidget {
  const _CodePrivilege({required this.controller});

  final TextEditingController controller;

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
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                size: 13,
                color: ClosetColors.fond500,
              ),
              const SizedBox(width: AppSpacing.gapChip),
              Text(
                'Code privilège'.toUpperCase(),
                style: ClosetTextStyles.meta.copyWith(
                  letterSpacing: 1.30,
                  color: ClosetColors.fond500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    style: ClosetTextStyles.nomProduit.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: InputDecoration(
                      hintText: 'cercle-privilège',
                      hintStyle: ClosetTextStyles.nomProduit.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: ClosetColors.placeholderGris,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p12,
                      ),
                      border: _bordure(),
                      enabledBorder: _bordure(),
                      focusedBorder: _bordure(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.p16),
              SizedBox(
                width: 114,
                height: 38,
                child: Material(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Codes privilège bientôt disponibles.'),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Appliquer',
                        style: ClosetTextStyles.actionPetite.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _bordure() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: ClosetColors.fond300,
          width: AppStroke.fin,
        ),
      );
}

/// Sous-total, livraison, puis total à régler séparé par un filet doré.
class _Recapitulatif extends StatelessWidget {
  const _Recapitulatif({required this.sousTotal, required this.livraison});

  final double sousTotal;
  final double livraison;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LigneMontant(
          label: 'Sous-total',
          montant: sousTotal,
          couleurLabel: ClosetColors.fond500,
        ),
        const SizedBox(height: AppSpacing.p20),
        _LigneMontant(
          label: 'Livraison délicate',
          montant: livraison,
          couleurLabel: ClosetColors.fond500,
        ),
        const SizedBox(height: AppSpacing.p16),
        const Divider(
          color: ClosetColors.fond400,
          thickness: AppStroke.fin,
          height: AppStroke.fin,
        ),
        const SizedBox(height: AppSpacing.p16),
        _LigneMontant(
          label: 'total à régler',
          montant: sousTotal + livraison,
          couleurLabel: ClosetColors.noir,
          grand: true,
        ),
      ],
    );
  }
}

class _LigneMontant extends StatelessWidget {
  const _LigneMontant({
    required this.label,
    required this.montant,
    required this.couleurLabel,
    this.grand = false,
  });

  final String label;
  final double montant;
  final Color couleurLabel;
  final bool grand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label.toUpperCase(),
          style: ClosetTextStyles.meta.copyWith(color: couleurLabel),
        ),
        Text(
          formatPrixFcfa(montant),
          style: grand
              ? ClosetTextStyles.prixGrand.copyWith(color: ClosetColors.vert)
              : ClosetTextStyles.prix.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.30,
                  color: ClosetColors.vert,
                ),
        ),
      ],
    );
  }
}

/// CTA « Finaliser Ma sélection » : 312 × 44, vert profond, rayon 100.
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
                'Finaliser Ma sélection',
                style: ClosetTextStyles.bouton.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
