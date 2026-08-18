import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
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
      appBar: const ClosetAppBar(showBackButton: true),
      body: pieces.isEmpty
          ? const _SelectionVide()
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.p32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.p20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                    child: Text(
                      pieces.length == 1
                          ? '1 pièce unique mise de côté pour vous.'
                          : '${pieces.length} pièces uniques mises de côté '
                              'pour vous.',
                      style: ClosetTextStyles.citation.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ClosetColors.noir,
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
                    child: _CodePrivilege(
                      controller: _codePrivilege,
                      onModifie: () => setState(() {}),
                    ),
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
                      fontStyle: FontStyle.italic,
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

/// Rangée « Code privilège » — maquette : ticket, libellé, invitation, chevron.
class _CodePrivilege extends StatelessWidget {
  const _CodePrivilege({required this.controller, required this.onModifie});

  final TextEditingController controller;
  final VoidCallback onModifie;

  @override
  Widget build(BuildContext context) {
    final saisi = controller.text.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        side: const BorderSide(
          color: ClosetColors.fond300,
          width: AppStroke.fin,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        onTap: () => _ouvrirSaisie(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p16,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 22,
                color: ClosetColors.vert,
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CODE PRIVILÈGE',
                      style: ClosetTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.30,
                        color: ClosetColors.noir,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      saisi ? controller.text.trim() : 'Veuillez rentrer votre code',
                      style: ClosetTextStyles.corps.copyWith(
                        color: ClosetColors.taupe,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: ClosetColors.noir,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ouvrirSaisie(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClosetColors.beige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.surface)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.p24,
            AppSpacing.p24,
            AppSpacing.p24,
            MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.p24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code privilège',
                style: ClosetTextStyles.titreBloc,
              ),
              const SizedBox(height: AppSpacing.p16),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                autofocus: true,
                style: ClosetTextStyles.saisie,
                cursorColor: ClosetColors.vert,
                decoration: InputDecoration(
                  hintText: 'Veuillez rentrer votre code',
                  hintStyle: ClosetTextStyles.saisieHint,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p12,
                  ),
                  border: _bordure(),
                  enabledBorder: _bordure(),
                  focusedBorder: _bordure(),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Material(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () {
                      Navigator.pop(ctx);
                      onModifie();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Codes privilège bientôt disponibles.'),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        'Appliquer',
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
        );
      },
    );
  }

  static OutlineInputBorder _bordure() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
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
              ? ClosetTextStyles.prixGrand.copyWith(
                  fontStyle: FontStyle.italic,
                  color: ClosetColors.vert,
                )
              : ClosetTextStyles.prix.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: SizedBox(
        width: double.infinity,
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
