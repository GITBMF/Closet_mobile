import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
<<<<<<< HEAD
=======
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_sections.dart';
>>>>>>> origin/main
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

<<<<<<< HEAD
  String _formatPrice(double price) {
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final remainder = intPrice % 1000;
      if (remainder == 0) {
        return '$thousands.000 FCFA';
      }
      return '$thousands.${remainder.toString().padLeft(3, '0')} FCFA';
    }
    return '$intPrice FCFA';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartListProvider);
    final subtotal = ref.watch(cartTotalProvider);
    const shippingFee = 3500.0; // Updated shipping fee to match mockup: 3.500 FCFA
    final total = subtotal > 0 ? subtotal + shippingFee : 0.0;

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/collections');
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: ClosetColors.vertFonce,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 18,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_none,
                size: 18,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: cartItems.isEmpty
          ? const _EmptyCart()
          : Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120), // Spacing for bottom button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Ma sélection',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // Subtitle
                        Text(
                          cartItems.length == 1
                              ? '1 pièce unique mise de côté pour vous.'
                              : '${cartItems.length} pièces uniques mises de côté pour vous.',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: ClosetColors.doreEncre,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // List of items
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final item = cartItems[i];
                            return _CartItem(
                              article: item,
                              onRemove: () {
                                final articleToRemove = item;
                                ref.read(cartProvider.notifier).removeArticle(articleToRemove.id);
                                
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${articleToRemove.title}" retirée de la sélection'),
                                    duration: const Duration(seconds: 5),
                                    action: SnackBarAction(
                                      label: 'Annuler',
                                      textColor: ClosetColors.doreClair,
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).addArticle(articleToRemove);
                                      },
                                    ),
                                    backgroundColor: ClosetColors.vertFonce,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              onTap: () => context.push('/product/${item.id}'),
                              formatPrice: _formatPrice,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Code Privilège Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_number_outlined,
                                      size: 16, color: ClosetColors.doreEncre),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CODE PRIVILÈGE',
                                    style: GoogleFonts.lato(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: ClosetColors.doreEncre,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: ClosetColors.ligne),
                                      ),
                                      child: TextField(
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: ClosetColors.taupe,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'CERCLE-PRIVILÈGE',
                                          hintStyle: GoogleFonts.lato(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: ClosetColors.ligne,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      // Apply coupon logic
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: ClosetColors.vertFonce,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'APPLIQUER',
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary breakdown directly on page background
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SOUS-TOTAL',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.taupe,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              _formatPrice(subtotal),
                              style: GoogleFonts.lato(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LIVRAISON DÉLICATE',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.taupe,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              _formatPrice(shippingFee),
                              style: GoogleFonts.lato(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL À RÉGLER',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.noir,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              _formatPrice(total),
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Checkout Button
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Consumer(
                    builder: (context, ref, _) {
                      return GestureDetector(
                        onTap: () {
                          context.push('/checkout');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ClosetColors.vertFonce,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Finaliser Ma sélection',
                              style: GoogleFonts.lato(
                                color: ClosetColors.creme,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
=======
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
>>>>>>> origin/main
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
<<<<<<< HEAD
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 170,
              decoration: BoxDecoration(
                color: ClosetColors.creme,
                border: Border.all(color: ClosetColors.dore, width: 1.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(65),
                  topRight: Radius.circular(65),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  '⧉',
                  style: TextStyle(
                    fontSize: 34,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ),
=======
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size: 48,
              color: ClosetColors.fond300,
>>>>>>> origin/main
            ),
            const SizedBox(height: AppSpacing.p20),
            Text(
              'Votre sélection est vide',
              textAlign: TextAlign.center,
<<<<<<< HEAD
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ClosetColors.vertFonce,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Les pièces de notre sélection sont uniques — laissez-vous guider par les nouveautés de la semaine.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: ClosetColors.taupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => context.go('/collections'),
              child: Container(
                constraints: const BoxConstraints(minWidth: 220),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Découvrir les Collections',
                  style: GoogleFonts.lato(
                    color: ClosetColors.creme,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
=======
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
>>>>>>> origin/main
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

<<<<<<< HEAD
// ── Cart Item Card ───────────────────────────────────────────────────────────

class _CartItem extends StatelessWidget {
  final Article article;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final String Function(double) formatPrice;

  const _CartItem({
=======
/// Ligne de pièce : carte blanche 350 × 146 cerclée d'or, visuel 107 × 127.
class _LignePiece extends StatelessWidget {
  const _LignePiece({
>>>>>>> origin/main
    required this.article,
    required this.onRetirer,
    required this.onTap,
<<<<<<< HEAD
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: article.imageUrls.isNotEmpty
                      ? Image.network(
                          article.imageUrls.first,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 80,
                            height: 100,
                            color: ClosetColors.ligne,
                            child: const Icon(Icons.image_not_supported_outlined, color: ClosetColors.taupe),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 100,
                          color: ClosetColors.ligne,
                          child: const Icon(Icons.image_not_supported_outlined, color: ClosetColors.taupe),
                        ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.brand.toUpperCase(),
                        style: GoogleFonts.lato(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.doreEncre,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ClosetColors.noir,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildConditionBadge(article.condition),
                      const SizedBox(height: 8),
                      Text(
                        formatPrice(article.price),
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove Button at top right
          Positioned(
            top: 10,
            right: 10,
            child: Semantics(
              button: true,
              label: 'Retirer ${article.title} de ma sélection',
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: ClosetColors.noir,
                  ),
                ),
              ),
            ),
=======
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
>>>>>>> origin/main
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildConditionBadge(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFA0D0BD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        condition.toUpperCase(),
        style: GoogleFonts.lato(
          color: ClosetColors.vertFonce,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
=======

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
>>>>>>> origin/main
        ),
      ),
    );
  }
}
