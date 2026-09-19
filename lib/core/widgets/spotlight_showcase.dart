import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/closet_l10n.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Clés globales posées sur les éléments réels que la visite guidée cible.
///
/// Une clé non montée n'est pas une erreur : l'étape correspondante est sautée
/// (voir [SpotlightShowcase]), ce qui permet de décrire des écrans dont le
/// contenu dépend des données du compte.
class ClosetTourKeys {
  ClosetTourKeys._();

  // ── En-tête (ClosetAppBar) ──
  static final selectionKey = GlobalKey(debugLabel: 'tour_selection');
  static final notificationsKey = GlobalKey(debugLabel: 'tour_notifications');

  // ── Barre de navigation ──
  static final dressingNavKey = GlobalKey(debugLabel: 'tour_dressing_nav');
  static final collectionsNavKey = GlobalKey(debugLabel: 'tour_collections_nav');
  static final wishlistNavKey = GlobalKey(debugLabel: 'tour_wishlist_nav');
  static final selectionNavKey = GlobalKey(debugLabel: 'tour_selection_nav');
  static final espaceNavKey = GlobalKey(debugLabel: 'tour_espace_nav');

  // ── Mon dressing ──
  static final pieceSemaineKey = GlobalKey(debugLabel: 'tour_piece_semaine');
  static final decouvrirKey = GlobalKey(debugLabel: 'tour_decouvrir');
  static final grilleKey = GlobalKey(debugLabel: 'tour_grille');

  // ── Collections ──
  static final rechercheKey = GlobalKey(debugLabel: 'tour_recherche');
  static final filtresKey = GlobalKey(debugLabel: 'tour_filtres');
  static final universKey = GlobalKey(debugLabel: 'tour_univers');

  // ── Fiche produit ──
  static final produitCarrouselKey = GlobalKey(debugLabel: 'tour_carrousel');
  static final produitFavoriKey = GlobalKey(debugLabel: 'tour_produit_favori');
  static final produitAjoutKey = GlobalKey(debugLabel: 'tour_produit_ajout');

  // ── Favoris / sélection ──
  static final wishlistAjoutKey = GlobalKey(debugLabel: 'tour_wishlist_ajout');
  static final finaliserKey = GlobalKey(debugLabel: 'tour_finaliser');

  // ── Mon espace ──
  static final espaceProfilKey = GlobalKey(debugLabel: 'tour_espace_profil');
  static final espaceSourceurKey = GlobalKey(debugLabel: 'tour_espace_sourceur');
  static final espaceCommandesKey = GlobalKey(debugLabel: 'tour_commandes');
  static final espaceLangueKey = GlobalKey(debugLabel: 'tour_langue');
  static final espaceVisiteKey = GlobalKey(debugLabel: 'tour_revoir');

  // ── Livraison et paiement ──
  static final checkoutNomKey = GlobalKey(debugLabel: 'tour_checkout_nom');
  static final checkoutTelKey = GlobalKey(debugLabel: 'tour_checkout_tel');
  static final checkoutVilleKey = GlobalKey(debugLabel: 'tour_checkout_ville');
  static final checkoutQuartierKey =
      GlobalKey(debugLabel: 'tour_checkout_quartier');
  static final checkoutDetailleeKey =
      GlobalKey(debugLabel: 'tour_checkout_detaillee');
  static final checkoutSuivantKey =
      GlobalKey(debugLabel: 'tour_checkout_suivant');
  static final checkoutMoyensKey = GlobalKey(debugLabel: 'tour_checkout_moyens');
  static final checkoutCodeKey = GlobalKey(debugLabel: 'tour_checkout_code');
  static final checkoutRecapKey = GlobalKey(debugLabel: 'tour_checkout_recap');
  static final checkoutPayerKey = GlobalKey(debugLabel: 'tour_checkout_payer');
}

/// Arrêt de la visite guidée : une zone éclairée, son explication, et ce qu'il
/// faut faire pour l'atteindre.
class SpotlightStep {
  const SpotlightStep({
    required this.targetKey,
    required this.ecran,
    required this.title,
    required this.description,
    this.borderRadius = 100,
    this.aller,
    this.disponible,
  });

  final GlobalKey targetKey;

  /// Nom de l'écran visité, affiché en surtitre de l'infobulle.
  final String ecran;

  final String title;
  final String description;
  final double borderRadius;

  /// Amène l'app sur l'écran de l'étape. `null` = rester sur place.
  final void Function(BuildContext context, WidgetRef ref)? aller;

  /// `false` = étape hors de portée (compte absent, sélection vide…) : elle est
  /// sautée sans même tenter la navigation.
  final bool Function(WidgetRef ref)? disponible;
}

/// État de la visite guidée.
class SpotlightTourState {
  const SpotlightTourState({required this.isActive, required this.currentStep});

  final bool isActive;
  final int currentStep;

  SpotlightTourState copyWith({bool? isActive, int? currentStep}) {
    return SpotlightTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class SpotlightTourNotifier extends Notifier<SpotlightTourState> {
  @override
  SpotlightTourState build() {
    return const SpotlightTourState(isActive: false, currentStep: 0);
  }

  void startTour() {
    state = const SpotlightTourState(isActive: true, currentStep: 0);
  }

  void nextStep(int maxSteps) {
    if (state.currentStep < maxSteps - 1) {
      HapticFeedback.lightImpact();
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      stopTour();
    }
  }

  void previousStep() {
    if (state.currentStep == 0) return;
    HapticFeedback.lightImpact();
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void stopTour() {
    HapticFeedback.mediumImpact();
    state = const SpotlightTourState(isActive: false, currentStep: 0);
  }
}

final spotlightTourProvider =
    NotifierProvider<SpotlightTourNotifier, SpotlightTourState>(() {
  return SpotlightTourNotifier();
});

/// Dessine le masque sombre sur l'écran avec une découpe transparente
/// (spotlight) autour de la cible.
class SpotlightPainter extends CustomPainter {
  const SpotlightPainter({required this.targetRect, this.borderRadius = 8});

  final Rect targetRect;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final maskPaint = Paint()..color = Colors.black.withValues(alpha: 0.72);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect.inflate(6),
        Radius.circular(borderRadius),
      ));

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, maskPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Visite guidée en surbrillance, posée une fois à la racine de l'app
/// ([main.dart]).
///
/// Reste inerte (`child` seul, sans masque) tant qu'aucune visite n'est active.
/// Une fois [SpotlightTourNotifier.startTour] appelé, chaque étape :
/// 1. vérifie qu'elle est jouable ([SpotlightStep.disponible]) ;
/// 2. navigue vers son écran ([SpotlightStep.aller]) ;
/// 3. attend que sa cible soit montée, puis la ramène dans la fenêtre si elle
///    est sortie du défilement ;
/// 4. éclaire la cible et pose l'infobulle du côté le plus dégagé.
///
/// Une cible qui ne se montre pas dans le délai imparti fait sauter l'étape :
/// la visite ne peut jamais rester bloquée sur un écran muet.
class SpotlightShowcase extends ConsumerStatefulWidget {
  const SpotlightShowcase({
    super.key,
    required this.child,
    required this.steps,
  });

  final Widget child;
  final List<SpotlightStep> steps;

  @override
  ConsumerState<SpotlightShowcase> createState() => _SpotlightShowcaseState();
}

class _SpotlightShowcaseState extends ConsumerState<SpotlightShowcase> {
  /// Étape dont la navigation a déjà été jouée.
  int _etapePreparee = -1;

  /// Frames passées à attendre la cible de l'étape courante.
  int _framesDAttente = 0;

  /// Recentrage déjà demandé pour l'étape courante.
  bool _recentre = false;

  /// Au-delà de ce délai, la cible est tenue pour absente de l'écran et l'étape
  /// est sautée. Sans ce garde-fou la visite resterait invisible et bloquée.
  static const _framesMax = 90;

  /// Prépare l'étape : saute celles hors de portée, navigue vers les autres.
  void _preparer(SpotlightStep step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!(step.disponible?.call(ref) ?? true)) {
        ref.read(spotlightTourProvider.notifier).nextStep(widget.steps.length);
        return;
      }
      step.aller?.call(context, ref);
      setState(() {});
    });
  }

  /// Retente la localisation à la frame suivante, et saute l'étape si la cible
  /// se fait trop attendre.
  void _attendreCible() {
    _framesDAttente++;
    final abandonne = _framesDAttente >= _framesMax;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (abandonne) {
        _framesDAttente = 0;
        ref.read(spotlightTourProvider.notifier).nextStep(widget.steps.length);
      } else {
        setState(() {});
      }
    });
  }

  /// Ramène la cible dans la fenêtre quand elle est sortie du défilement —
  /// sinon le projecteur éclairerait une zone hors écran.
  void _recentrerSurCible(BuildContext cible) {
    _recentre = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || Scrollable.maybeOf(cible) == null) return;
      await Scrollable.ensureVisible(
        cible,
        alignment: 0.5,
        duration: Duration.zero,
      );
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(spotlightTourProvider);

    if (!tourState.isActive || widget.steps.isEmpty) {
      _etapePreparee = -1;
      return widget.child;
    }

    final index = tourState.currentStep.clamp(0, widget.steps.length - 1);
    final step = widget.steps[index];

    if (_etapePreparee != index) {
      _etapePreparee = index;
      _framesDAttente = 0;
      _recentre = false;
      // La navigation a besoin d'une frame : l'écran d'arrivée n'est pas encore
      // construit, donc sa cible n'est pas encore localisable.
      _preparer(step);
      return widget.child;
    }

    final targetContext = step.targetKey.currentContext;
    final renderBox = targetContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.attached) {
      _attendreCible();
      return widget.child;
    }
    _framesDAttente = 0;

    final ecran = MediaQuery.sizeOf(context);
    final marges = MediaQuery.paddingOf(context);
    final position = renderBox.localToGlobal(Offset.zero);
    final cible = Rect.fromLTWH(
      position.dx,
      position.dy,
      renderBox.size.width,
      renderBox.size.height,
    );

    final horsFenetre = cible.bottom > ecran.height || cible.top < 0;
    if (horsFenetre && !_recentre) {
      _recentrerSurCible(targetContext!);
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: CustomPaint(
            painter: SpotlightPainter(
              targetRect: cible,
              borderRadius: step.borderRadius,
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref
                .read(spotlightTourProvider.notifier)
                .nextStep(widget.steps.length),
          ),
        ),
        _Infobulle(
          step: step,
          index: index,
          total: widget.steps.length,
          cible: cible,
          ecran: ecran,
          marges: marges,
        ),
      ],
    );
  }
}

/// Carte d'explication, posée du côté le plus dégagé de la cible.
class _Infobulle extends ConsumerWidget {
  const _Infobulle({
    required this.step,
    required this.index,
    required this.total,
    required this.cible,
    required this.ecran,
    required this.marges,
  });

  final SpotlightStep step;
  final int index;
  final int total;
  final Rect cible;
  final Size ecran;
  final EdgeInsets marges;

  static const _ecart = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final visite = ref.read(spotlightTourProvider.notifier);

    // Le côté retenu est celui qui offre le plus de place : placer l'infobulle
    // au-dessus d'une grande carte la recouvrirait entièrement, alors que c'est
    // précisément ce que l'étape veut montrer.
    final placeDessous = ecran.height - cible.bottom - marges.bottom;
    final placeDessus = cible.top - marges.top;
    final dessous = placeDessous >= placeDessus;

    return Positioned(
      left: 20,
      right: 20,
      top: dessous ? cible.bottom + _ecart : null,
      bottom: dessous ? null : (ecran.height - cible.top) + _ecart,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ClosetColors.ivoire,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ClosetColors.dore, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${step.ecran} · ${l10n.tourEtape(index + 1, total)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.labelChamp.copyWith(
                      color: ClosetColors.doreEncre,
                      fontSize: 10,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: visite.stopTour,
                  child: Text(
                    l10n.tourPasser,
                    style: ClosetTextStyles.labelChamp.copyWith(
                      color: ClosetColors.texteSecondaire,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              step.title,
              style: ClosetTextStyles.titreEcran.copyWith(
                fontSize: 18,
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.description,
              style: ClosetTextStyles.corps.copyWith(
                fontSize: 13,
                height: 1.45,
                color: ClosetColors.noir.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (index > 0)
                  TextButton(
                    onPressed: visite.previousStep,
                    child: Text(
                      l10n.tourPrecedent,
                      style: ClosetTextStyles.labelChamp.copyWith(
                        color: ClosetColors.texteSecondaire,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClosetColors.vert,
                    foregroundColor: ClosetColors.creme,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => visite.nextStep(total),
                  child: Text(
                    index == total - 1 ? l10n.tourTerminer : l10n.tourSuivant,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
