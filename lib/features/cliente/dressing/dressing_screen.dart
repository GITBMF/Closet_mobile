import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

<<<<<<< HEAD
import '../../../core/services/notification_service.dart';
import '../../../core/theme/closet_colors.dart';
=======
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/piece_card.dart';
>>>>>>> origin/main
import '../../../data/models/article.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../collections/collections_screen.dart';

final dressingDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch<CatalogRepository>(catalogRepositoryProvider);
  final featured = await repo.getFeatured();
<<<<<<< HEAD
  final newArrivals = await repo.getNewArrivals();
  final coupDeCoeur = await repo.getCoupDeCoeur();
=======
  final allArticles = await repo.getCatalog();

  final Map<String, List<Article>> grouped = {};
  for (final category in CatalogRepository.categories) {
    final list = allArticles
        .where((a) => a.universe.toLowerCase() == category.toLowerCase())
        .toList();
    if (list.isNotEmpty) {
      grouped[category] = list;
    }
  }

>>>>>>> origin/main
  return {
    'featured': featured,
    'newArrivals': newArrivals,
    'coupDeCoeur': coupDeCoeur,
  };
});

/// Accueil « dressing » — transcription de la maquette Figma `11:30` / `11:250`.
///
/// Carte « pièce de la semaine » en arche, visuel à la une, puis deux grilles
/// de deux colonnes séparées par des titres Cormorant et des liens dorés.
class DressingScreen extends ConsumerWidget {
  const DressingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dressingDataProvider);
<<<<<<< HEAD
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: AppBar(
        backgroundColor: ClosetColors.beige,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left profile welcome
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenue,',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.noir,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Mme ${user?.firstName ?? 'Aïcha'} N.',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ClosetColors.doreEncre,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Center Logo
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/iconheader.png',
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text('ClosET', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              // Right actions
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Panier',
                      child: GestureDetector(
                        onTap: () => context.go('/selection'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: ClosetColors.vertFonce,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Notifications',
                      child: GestureDetector(
                        onTap: () {
                          ref.read(notificationProvider.notifier).show(
                                'Notifications',
                                'Aucune nouvelle notification pour le moment.',
                              );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            color: ClosetColors.vertFonce,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: ClosetColors.ligne,
            height: 1,
          ),
        ),
      ),
      body: asyncData.when(
        data: (data) {
          final featured = data['featured'] as Article;
          final newArrivals = data['newArrivals'] as List<Article>;
          final coupDeCoeur = data['coupDeCoeur'] as List<Article>;
          return _HomeBody(
            featured: featured,
            newArrivals: newArrivals,
            coupDeCoeur: coupDeCoeur,
          );
        },
=======

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: const ClosetAppBar(),
      body: asyncData.when(
        data: (data) => _CorpsAccueil(
          featured: data['featured'] as Article,
          grouped: data['grouped'] as Map<String, List<Article>>,
        ),
>>>>>>> origin/main
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
      ),
    );
  }
}

class _CorpsAccueil extends ConsumerWidget {
  const _CorpsAccueil({required this.featured, required this.grouped});

  final Article featured;
  final List<Article> newArrivals;
  final List<Article> coupDeCoeur;

<<<<<<< HEAD
  const _HomeBody({
    required this.featured,
    required this.newArrivals,
    required this.coupDeCoeur,
  });
=======
  /// Marge latérale de l'écran dans la maquette.
  static const double _marge = 20;
>>>>>>> origin/main

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
<<<<<<< HEAD
    final wishlist = ref.watch(wishlistListProvider);
    final isWishlisted = wishlist.any((a) => a.id == featured.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Pièce de la semaine ────────────────────────────────────
          // 1. Arch Text Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: ClosetColors.vertFonce,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PIÈCE DE LA SEMAINE',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: ClosetColors.dore,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  featured.title,
                  style: GoogleFonts.ebGaramond(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${featured.brand}. ${featured.material}. T${featured.size}. Pièce Unique',
                  style: GoogleFonts.lato(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.push('/product/${featured.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: ClosetColors.dore,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Découvrir - ${_formatPrice(featured.price)}',
                      style: GoogleFonts.lato(
                        color: ClosetColors.vertFonce,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Photo Card below the arch
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/product/${featured.id}'),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ClosetColors.ligne, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE7DCC6), Color(0xFFD6C6A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Image on top
                    if (featured.imageUrls.isNotEmpty)
                      Semantics(
                        label: 'Photo de la pièce de la semaine: ${featured.title}',
                        child: Image.network(
                          featured.imageUrls[0],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                    // Condition Tag (Excellent état style)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6EBE0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          featured.condition.toUpperCase(),
                          style: GoogleFonts.lato(
                            color: const Color(0xFF224235),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    // Wishlist Toggle
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Semantics(
                        button: true,
                        label: isWishlisted ? 'Retirer des favoris' : 'Ajouter aux favoris',
                        child: GestureDetector(
                          onTap: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(featured);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isWishlisted ? ClosetColors.erreur : ClosetColors.vertFonce,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── EXPLORER PAR UNIVERS ───────────────────────────────────
          Text(
            'EXPLORER PAR UNIVERS',
            style: GoogleFonts.lato(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: ClosetColors.doreEncre,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                'Tout l\'univers',
                'Robes',
                'Vestes',
                'Sacs',
                'Escarpins',
                'Accessoires',
              ].map((category) {
                final isSelectedCategory = category == ref.watch(selectedUniverseProvider);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedUniverseProvider.notifier).setUniverse(category);
                      context.go('/collections');
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelectedCategory ? ClosetColors.vertFonce : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: isSelectedCategory
                            ? null
                            : Border.all(color: ClosetColors.ligne, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: GoogleFonts.lato(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isSelectedCategory ? Colors.white : ClosetColors.vertFonce,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // ─── Nouveautés du dressing ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Nouveauté du dressing',
                style: GoogleFonts.ebGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ClosetColors.vertFonce,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                  context.go('/collections');
                },
                child: Text(
                  'TOUT DÉCOUVRIR →',
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (newArrivals.isNotEmpty)
                Expanded(
                  child: _PieceCard(article: newArrivals[0], formatPrice: _formatPrice),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 10),
              if (newArrivals.length > 1)
                Expanded(
                  child: _PieceCard(article: newArrivals[1], formatPrice: _formatPrice),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 28),

          // ─── Coup de cœur Clos ET ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Coup de cœur Clos ET',
                style: GoogleFonts.ebGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ClosetColors.vertFonce,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                  context.go('/collections');
                },
                child: Text(
                  'VOIR →',
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coupDeCoeur.isNotEmpty)
                Expanded(
                  child: _PieceCard(article: coupDeCoeur[0], formatPrice: _formatPrice),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 10),
              if (coupDeCoeur.length > 1)
                Expanded(
                  child: _PieceCard(article: coupDeCoeur[1], formatPrice: _formatPrice),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 28),

          // ─── Maison du moment ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Maison du moment',
                style: GoogleFonts.ebGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ClosetColors.vertFonce,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go('/collections');
                },
                child: Text(
                  'TOUTES →',
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                'Tout l\'univers',
                'Robes',
                'Vestes',
                'Sacs',
                'Escarpins',
                'Accessoires',
              ].map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedUniverseProvider.notifier).setUniverse(category);
                      context.go('/collections');
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ClosetColors.ligne, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: GoogleFonts.lato(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 36),

          // ─── Footer Slogan ──────────────────────────────────────────
          Center(
            child: Text(
              'CLOS ET. ABIDJAN - PARIS - YAOUNDÉ',
              style: GoogleFonts.lato(
                fontSize: 10,
                letterSpacing: 2.5,
                color: ClosetColors.noir.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
=======
    final tous = [for (final liste in grouped.values) ...liste];
    final nouveautes = tous.take(4).toList();
    final coupsDeCoeur = tous.skip(4).take(4).toList();
    final univers = grouped.keys.toList();

    void ouvrirUnivers(String categorie) {
      ref
          .read<UniverseNotifier>(selectedUniverseProvider.notifier)
          .setUniverse(categorie);
      context.go('/collections');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.p32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 23),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _marge),
            child: _CartePieceDeLaSemaine(
              article: featured,
              onTap: () => context.push('/product/${featured.id}'),
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: _CarteALaUne(
              article: featured,
              onTap: () => context.push('/product/${featured.id}'),
            ),
          ),
          const SizedBox(height: 33),
          if (univers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 19),
              child: ClosetSurtitre('explorer par univers'),
            ),
            const SizedBox(height: AppSpacing.p16),
            _RangeeUnivers(univers: univers, onTap: ouvrirUnivers),
            const SizedBox(height: AppSpacing.p20),
          ],
          if (nouveautes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: ClosetEnTeteSection(
                titre: 'Nouveauté du dressing',
                lien: 'tout découvrir',
                onLien: () => context.go('/collections'),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            _GrilleArticles(articles: nouveautes, marge: 21),
          ],
          if (coupsDeCoeur.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: ClosetEnTeteSection(
                titre: 'Coup de coeur Clos ET',
                lien: 'voir',
                onLien: () => context.go('/collections'),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            _GrilleArticles(articles: coupsDeCoeur, marge: 21),
          ],
          if (univers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: ClosetEnTeteSection(
                titre: 'Maison du moment',
                lien: 'toutes',
                onLien: () => context.go('/collections'),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            _RangeeUnivers(univers: univers, onTap: ouvrirUnivers),
          ],
          const ClosetSignature(),
        ],
      ),
    );
  }
}

/// Carte « pièce de la semaine » : 350 × 120, vert profond, coins supérieurs
/// très arrondis (102 / 130) qui lui donnent sa silhouette en arche.
class _CartePieceDeLaSemaine extends StatelessWidget {
  const _CartePieceDeLaSemaine({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(102),
          topRight: Radius.circular(130),
          bottomLeft: Radius.circular(AppRadius.carte),
          bottomRight: Radius.circular(AppRadius.carte),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'pièce de la semaine'.toUpperCase(),
            style: ClosetTextStyles.surtitre.copyWith(
              color: ClosetColors.fond400,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Text(
            article.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.accroche.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.p4),
          Text(
            '${article.brand}. ${article.material}. T${article.size}.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.attribut.copyWith(
              letterSpacing: 0,
              color: ClosetColors.fond200,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          SizedBox(
            width: 236,
            height: 34,
            child: Material(
              color: ClosetColors.fond300,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: onTap,
                child: Center(
                  child: Text(
                    'Découvrir - ${formatPrixFcfa(article.price)}',
                    style: ClosetTextStyles.bouton.copyWith(
                      color: ClosetColors.neutre1000,
                    ),
                  ),
                ),
>>>>>>> origin/main
              ),
            ),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class _PieceCard extends ConsumerWidget {
  final Article article;
  final String Function(double) formatPrice;

  const _PieceCard({
    required this.article,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistListProvider);
    final isWishlisted = wishlist.any((a) => a.id == article.id);

    return MergeSemantics(
      child: Semantics(
        label: '${article.brand}, ${article.title}, ${formatPrice(article.price)}, état: ${article.condition}',
        child: GestureDetector(
          onTap: () => context.push('/product/${article.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ClosetColors.ligne, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo area
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE7DCC6), Color(0xFFD6C6A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Silhouette placeholder
                      Center(
                        child: Container(
                          width: 55,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1C3D2F).withValues(alpha: 0.14),
                                const Color(0xFF12241D).withValues(alpha: 0.4),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Image on top
                      if (article.imageUrls.isNotEmpty)
                        Image.network(
                          article.imageUrls[0],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      // Tag État (Condition)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EBE0),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            article.condition.split(' ').first.toUpperCase(),
                            style: GoogleFonts.lato(
                              color: const Color(0xFF224235),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      // Heart Icon Button
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Semantics(
                          button: true,
                          label: isWishlisted ? 'Retirer des favoris' : 'Ajouter aux favoris',
                          child: GestureDetector(
                            onTap: () {
                              ref.read(wishlistProvider.notifier).toggleWishlist(article);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isWishlisted ? ClosetColors.erreur : ClosetColors.vertFonce,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Metadata
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAISON ${article.brand.toUpperCase()}',
                        style: GoogleFonts.lato(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: ClosetColors.doreEncre,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article.title,
                        style: GoogleFonts.ebGaramond(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.5,
                          color: ClosetColors.noir,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatPrice(article.price),
                        style: GoogleFonts.ebGaramond(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'T.${article.size}. ${article.material}',
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: ClosetColors.taupe,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
=======
/// Visuel à la une : carte de 350 × 184 dont l'image occupe 326 × 160.
class _CarteALaUne extends StatelessWidget {
  const _CarteALaUne({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 184,
        padding: const EdgeInsets.all(AppSpacing.p12),
        decoration: BoxDecoration(
          color: ClosetColors.carteFond,
          border: Border.all(
            color: ClosetColors.carteBordure,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.carte),
              child: article.imageUrls.isEmpty
                  ? const ColoredBox(color: Color(0xFFE5E5E5))
                  : Image.network(
                      article.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFFE5E5E5)),
                    ),
            ),
            Positioned(
              top: AppSpacing.p12,
              left: AppSpacing.p8,
              child: Container(
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
            ),
            const Positioned(
              top: AppSpacing.p12,
              right: AppSpacing.p8,
              child: BoutonCoeur(actif: false),
            ),
          ],
>>>>>>> origin/main
        ),
      ),
    );
  }
}
<<<<<<< HEAD
=======



/// Rangée horizontale de puces d'univers. La première (« Tout l'univers »)
/// est active dans la maquette.
class _RangeeUnivers extends StatelessWidget {
  const _RangeeUnivers({required this.univers, required this.onTap});

  final List<String> univers;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: univers.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.p12),
        itemBuilder: (context, i) {
          if (i == 0) {
            return ClosetChip(
              label: 'Tout l’univers',
              isActive: true,
              onTap: () => context.go('/collections'),
            );
          }
          final categorie = univers[i - 1];
          return ClosetChip(
            label: categorie,
            onTap: () => onTap(categorie),
          );
        },
      ),
    );
  }
}

/// Grille de deux colonnes, cartes de 169 × 249 séparées de 12.
class _GrilleArticles extends StatelessWidget {
  const _GrilleArticles({required this.articles, required this.marge});

  final List<Article> articles;
  final double marge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marge),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: articles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.p12,
          mainAxisSpacing: AppSpacing.p12,
          childAspectRatio: PieceCard.ratioCarteGrille,
        ),
        itemBuilder: (context, i) {
          final article = articles[i];
          return ArticleCard(
            article: article,
            onTap: () => context.push('/product/${article.id}'),
          );
        },
      ),
    );
  }
}
>>>>>>> origin/main
