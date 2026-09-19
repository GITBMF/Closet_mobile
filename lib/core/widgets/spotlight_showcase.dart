import 'dart:math' as math;

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
  static final accueilKey = GlobalKey(debugLabel: 'tour_accueil');
  static final selectionKey = GlobalKey(debugLabel: 'tour_selection');
  static final notificationsKey = GlobalKey(debugLabel: 'tour_notifications');

  // ── Barre de navigation ──
  static final dressingNavKey = GlobalKey(debugLabel: 'tour_dressing_nav');
  static final collectionsNavKey = GlobalKey(
    debugLabel: 'tour_collections_nav',
  );
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
  static final espaceSourceurKey = GlobalKey(
    debugLabel: 'tour_espace_sourceur',
  );
  static final espaceCommandesKey = GlobalKey(debugLabel: 'tour_commandes');
  static final espaceLangueKey = GlobalKey(debugLabel: 'tour_langue');
  static final espaceVisiteKey = GlobalKey(debugLabel: 'tour_revoir');

  // ── Livraison et paiement ──
  static final checkoutNomKey = GlobalKey(debugLabel: 'tour_checkout_nom');
  static final checkoutTelKey = GlobalKey(debugLabel: 'tour_checkout_tel');
  static final checkoutVilleKey = GlobalKey(debugLabel: 'tour_checkout_ville');
  static final checkoutQuartierKey = GlobalKey(
    debugLabel: 'tour_checkout_quartier',
  );
  static final checkoutDetailleeKey = GlobalKey(
    debugLabel: 'tour_checkout_detaillee',
  );
  static final checkoutSuivantKey = GlobalKey(
    debugLabel: 'tour_checkout_suivant',
  );
  static final checkoutMoyensKey = GlobalKey(
    debugLabel: 'tour_checkout_moyens',
  );
  static final checkoutRecapKey = GlobalKey(debugLabel: 'tour_checkout_recap');
  static final checkoutPayerKey = GlobalKey(debugLabel: 'tour_checkout_payer');
}

/// Geste que la cliente doit faire sur la zone éclairée : la visite le mime
/// avec une main animée.
enum GesteVisite { aucun, appui, glisser, defiler }

/// Arrêt de la visite guidée : une zone éclairée, son explication, et ce qu'il
/// faut faire pour l'atteindre.
class SpotlightStep {
  const SpotlightStep({
    required this.targetKey,
    required this.ecran,
    required this.title,
    required this.description,
    this.borderRadius = 100,
    this.geste = GesteVisite.aucun,
    this.aller,
    this.disponible,
  });

  final GlobalKey targetKey;

  /// Nom de l'écran visité, affiché en surtitre de l'infobulle.
  final String ecran;

  final String title;
  final String description;
  final double borderRadius;

  /// Geste mimé par la main animée sur la zone éclairée.
  final GesteVisite geste;

  /// Amène l'app sur l'écran de l'étape. `null` = rester sur place.
  final void Function(BuildContext context, WidgetRef ref)? aller;

  /// `false` = étape hors de portée (compte absent, sélection vide…) : elle est
  /// sautée sans même tenter la navigation.
  final bool Function(WidgetRef ref)? disponible;
}

/// État de la visite guidée.
class SpotlightTourState {
  const SpotlightTourState({
    required this.isActive,
    required this.currentStep,
    this.sens = 1,
  });

  final bool isActive;
  final int currentStep;

  /// Direction du dernier déplacement : `1` en avant, `-1` en arrière. Une
  /// étape injouable est sautée dans ce même sens, pour que « Précédent » ne
  /// rebondisse pas sur elle.
  final int sens;

  SpotlightTourState copyWith({bool? isActive, int? currentStep, int? sens}) {
    return SpotlightTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      sens: sens ?? this.sens,
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
      state = state.copyWith(currentStep: state.currentStep + 1, sens: 1);
    } else {
      stopTour();
    }
  }

  void previousStep() {
    if (state.currentStep == 0) return;
    HapticFeedback.lightImpact();
    state = state.copyWith(currentStep: state.currentStep - 1, sens: -1);
  }

  /// Passe l'étape courante sans bruit, dans le sens du parcours.
  void sauterEtape(int maxSteps) {
    final suivante = state.currentStep + state.sens;
    if (suivante < 0) {
      state = state.copyWith(currentStep: state.currentStep + 1, sens: 1);
    } else if (suivante >= maxSteps) {
      stopTour();
    } else {
      state = state.copyWith(currentStep: suivante);
    }
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
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(6),
          Radius.circular(borderRadius),
        ),
      );

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

  /// Dernière zone éclairée : point de départ de l'animation vers la suivante.
  Rect? _derniereZone;

  /// Au-delà de ce délai, la cible est tenue pour absente de l'écran et l'étape
  /// est sautée. Sans ce garde-fou la visite resterait invisible et bloquée.
  static const _framesMax = 90;

  /// Prépare l'étape : saute celles hors de portée, navigue vers les autres.
  void _preparer(SpotlightStep step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!(step.disponible?.call(ref) ?? true)) {
        ref
            .read(spotlightTourProvider.notifier)
            .sauterEtape(widget.steps.length);
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
        ref
            .read(spotlightTourProvider.notifier)
            .sauterEtape(widget.steps.length);
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

  /// Voile qui absorbe les touches pendant qu'une étape se prépare : un appui
  /// ne doit jamais traverser vers l'écran en train de changer.
  Widget _attente() {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AbsorbPointer(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(spotlightTourProvider);

    if (!tourState.isActive || widget.steps.isEmpty) {
      _etapePreparee = -1;
      _derniereZone = null;
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
      return _attente();
    }

    final targetContext = step.targetKey.currentContext;
    final renderBox = targetContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.attached) {
      _attendreCible();
      return _attente();
    }
    _framesDAttente = 0;

    final ecran = MediaQuery.sizeOf(context);
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
      return _attente();
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: _Projecteur(
            step: step,
            index: index,
            total: widget.steps.length,
            depart:
                _derniereZone ??
                Rect.fromCenter(center: cible.center, width: 8, height: 8),
            onZone: (zone) => _derniereZone = zone,
          ),
        ),
      ],
    );
  }
}

/// Masque sombre, halo pulsé, main animée et infobulle d'une étape.
///
/// La zone éclairée glisse d'une cible à la suivante et suit sa cible à chaque
/// image : si l'écran défile ou change de taille, le projecteur reste dessus.
class _Projecteur extends ConsumerStatefulWidget {
  const _Projecteur({
    required this.step,
    required this.index,
    required this.total,
    required this.depart,
    required this.onZone,
  });

  final SpotlightStep step;
  final int index;
  final int total;
  final Rect depart;
  final ValueChanged<Rect> onZone;

  @override
  ConsumerState<_Projecteur> createState() => _ProjecteurState();
}

class _ProjecteurState extends ConsumerState<_Projecteur>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pouls = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  late Rect _zone = widget.depart;

  @override
  void dispose() {
    _pouls.dispose();
    super.dispose();
  }

  Rect? _mesurer() {
    final box =
        widget.step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final ecran = MediaQuery.sizeOf(context);
    final marges = MediaQuery.paddingOf(context);
    final visite = ref.read(spotlightTourProvider.notifier);

    return AnimatedBuilder(
      animation: _pouls,
      builder: (context, _) {
        final reel = _mesurer();
        if (reel != null) {
          final proche =
              (reel.center - _zone.center).distance < 0.5 &&
              (reel.width - _zone.width).abs() < 0.5 &&
              (reel.height - _zone.height).abs() < 0.5;
          _zone = proche ? reel : Rect.lerp(_zone, reel, 0.22)!;
          widget.onZone(_zone);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PeintreProjecteur(
                  zone: _zone,
                  rayon: widget.step.borderRadius,
                  pouls: _pouls.value,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => visite.nextStep(widget.total),
              ),
            ),
            if (widget.step.geste != GesteVisite.aucun)
              _MainGeste(
                geste: widget.step.geste,
                zone: _zone,
                t: _pouls.value,
              ),
            _Infobulle(
              step: widget.step,
              index: widget.index,
              total: widget.total,
              cible: _zone,
              ecran: ecran,
              marges: marges,
            ),
          ],
        );
      },
    );
  }
}

class _PeintreProjecteur extends CustomPainter {
  const _PeintreProjecteur({
    required this.zone,
    required this.rayon,
    required this.pouls,
  });

  final Rect zone;
  final double rayon;
  final double pouls;

  @override
  void paint(Canvas canvas, Size size) {
    final trou = RRect.fromRectAndRadius(
      zone.inflate(6),
      Radius.circular(rayon),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(trou),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.74),
    );

    canvas.drawRRect(
      trou,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ClosetColors.dore,
    );

    final t = Curves.easeOut.transform(pouls);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        zone.inflate(6 + 18 * t),
        Radius.circular(rayon + 18 * t),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = ClosetColors.dore.withValues(alpha: 0.8 * (1 - t)),
    );
  }

  @override
  bool shouldRepaint(covariant _PeintreProjecteur old) => true;
}

/// Main qui mime le geste attendu : appui, glissement ou défilement.
class _MainGeste extends StatelessWidget {
  const _MainGeste({required this.geste, required this.zone, required this.t});

  final GesteVisite geste;
  final Rect zone;
  final double t;

  static const _taille = 46.0;

  @override
  Widget build(BuildContext context) {
    // Va-et-vient doux : 0 → 1 → 0 sur un cycle.
    final aller = Curves.easeInOut.transform(t < 0.5 ? t * 2 : 2 - 2 * t);
    var pointe = zone.center + const Offset(8, 12);
    var echelle = 1.0;
    Widget? onde;

    switch (geste) {
      case GesteVisite.appui:
        echelle = 1 - 0.2 * math.sin(math.pi * t);
        final rayon = 10 + 34 * t;
        onde = Positioned(
          left: zone.center.dx - rayon,
          top: zone.center.dy - rayon,
          child: Container(
            width: rayon * 2,
            height: rayon * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.35 * (1 - t)),
            ),
          ),
        );
      case GesteVisite.glisser:
        final amp = math.min(zone.width * 0.3, 80.0);
        pointe = zone.center + Offset(-amp + 2 * amp * aller, 12);
      case GesteVisite.defiler:
        final amp = math.min(zone.height * 0.25, 70.0);
        pointe = zone.center + Offset(8, amp - 2 * amp * aller);
      case GesteVisite.aucun:
        break;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            ?onde,
            Positioned(
              left: pointe.dx - 0.4 * _taille,
              top: pointe.dy - 0.15 * _taille,
              child: Transform.scale(
                scale: echelle,
                alignment: const Alignment(-0.2, -0.7),
                child: const Icon(
                  Icons.touch_app_rounded,
                  size: _taille,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'explication, posée du côté le plus dégagé de la cible.
///
/// Sa hauteur est plafonnée à la place réellement disponible et le texte défile
/// à l'intérieur : quelle que soit la taille de police choisie, le titre, la
/// description et les boutons restent tous à l'écran.
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

  static const _ecart = 16.0;
  static const _bord = 16.0;

  /// Hauteur minimale pour lire titre, texte et boutons sans masquer la cible.
  static const _placeMin = 230.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final visite = ref.read(spotlightTourProvider.notifier);
    final dernier = index == total - 1;

    final placeDessous =
        ecran.height - cible.bottom - marges.bottom - _ecart - _bord;
    final placeDessus = cible.top - marges.top - _ecart - _bord;
    final meilleure = math.max(placeDessous, placeDessus);

    // Cible immense (grille entière, page défilante) : aucun côté n'offre la
    // place d'une infobulle. On l'ancre alors au bas de l'écran, sur la cible,
    // plutôt que de la laisser sortir de l'écran avec ses boutons.
    final ancree = meilleure < _placeMin;
    final dessous = ancree || placeDessous >= placeDessus;
    final hauteurMax = ancree
        ? ecran.height * 0.5
        : meilleure.clamp(
            _placeMin,
            ecran.height - marges.vertical - 2 * _bord,
          );

    return Positioned(
      left: _bord,
      right: _bord,
      top: !ancree && dessous ? cible.bottom + _ecart : null,
      bottom: ancree
          ? marges.bottom + _bord
          : dessous
          ? null
          : (ecran.height - cible.top) + _ecart,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(index),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, v, enfant) => Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * (dessous ? 18 : -18)),
            child: enfant,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: hauteurMax),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${step.ecran} · ${l10n.tourEtape(index + 1, total)}',
                        style: ClosetTextStyles.labelChamp.copyWith(
                          color: ClosetColors.doreEncre,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: visite.stopTour,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: ClosetColors.texteSecondaire,
                      ),
                      child: Text(
                        l10n.tourPasser,
                        style: ClosetTextStyles.labelChamp.copyWith(
                          color: ClosetColors.texteSecondaire,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: 3,
                    color: ClosetColors.dore,
                    backgroundColor: ClosetColors.ligne,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: ClosetTextStyles.titreEcran.copyWith(
                            fontSize: 22,
                            height: 1.2,
                            color: ClosetColors.noir,
                            fontFamily: GoogleFonts.ebGaramond().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.description,
                          style: ClosetTextStyles.corps.copyWith(
                            fontSize: 15,
                            height: 1.45,
                            color: ClosetColors.noir.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (index > 0)
                        TextButton(
                          onPressed: visite.previousStep,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 44),
                            foregroundColor: ClosetColors.texteSecondaire,
                          ),
                          child: Text(
                            l10n.tourPrecedent,
                            style: ClosetTextStyles.labelChamp.copyWith(
                              color: ClosetColors.texteSecondaire,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ClosetColors.vert,
                          foregroundColor: ClosetColors.creme,
                          minimumSize: const Size(96, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 0,
                        ),
                        onPressed: () => visite.nextStep(total),
                        child: Text(
                          dernier ? l10n.tourTerminer : l10n.tourSuivant,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
