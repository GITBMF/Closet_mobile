import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/closet_l10n.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Cibles de la visite — onglets, contrôles d’écran, et cibles du parcours distant.
class ClosetTourKeys {
  static final dressing = GlobalKey();
  static final collections = GlobalKey();
  static final wishlist = GlobalKey();
  static final selection = GlobalKey();
  static final espace = GlobalKey();
  static final barre = GlobalKey();
  static final filtres = GlobalKey();
  static final commandes = GlobalKey();
  static final sourceur = GlobalKey();

  static final accueilKey = GlobalKey();
  static final pieceSemaineKey = GlobalKey();
  static final decouvrirKey = GlobalKey();
  static final grilleKey = GlobalKey();
  static final selectionKey = GlobalKey();
  static final notificationsKey = GlobalKey();
  static final dressingNavKey = dressing;
  static final collectionsNavKey = collections;
  static final wishlistNavKey = wishlist;
  static final selectionNavKey = selection;
  static final espaceNavKey = espace;
  static final rechercheKey = GlobalKey();
  static final universKey = GlobalKey();
  static final filtresKey = filtres;
  static final produitCarrouselKey = GlobalKey();
  static final produitFavoriKey = GlobalKey();
  static final produitAjoutKey = GlobalKey();
  static final wishlistAjoutKey = GlobalKey();
  static final finaliserKey = GlobalKey();
  static final checkoutNomKey = GlobalKey();
  static final checkoutTelKey = GlobalKey();
  static final checkoutVilleKey = GlobalKey();
  static final checkoutQuartierKey = GlobalKey();
  static final checkoutDetailleeKey = GlobalKey();
  static final checkoutSuivantKey = GlobalKey();
  static final checkoutMoyensKey = GlobalKey();
  static final checkoutRecapKey = GlobalKey();
  static final checkoutPayerKey = GlobalKey();
  static final espaceProfilKey = GlobalKey();
  static final espaceSourceurKey = sourceur;
  static final espaceCommandesKey = commandes;
  static final espaceLangueKey = GlobalKey();
  static final espaceVisiteKey = GlobalKey();
  static final sourceurFicheKey = GlobalKey();
  static final sourceurDepotsNavKey = GlobalKey();
  static final sourceurTableauBordKey = GlobalKey();
  static final sourceurFiltresKey = GlobalKey();
  static final sourceurConfierNavKey = GlobalKey();
  static final sourceurEtapesKey = GlobalKey();
  static final sourceurGainsNavKey = GlobalKey();
  static final sourceurSoldeKey = GlobalKey();
  static final sourceurEspaceNavKey = GlobalKey();
}

class SpotlightStep {
  const SpotlightStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.route,
    this.fallbackKey,
    this.borderRadius = 20,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;

  /// Branche du shell à afficher avant de viser la cible.
  final String? route;

  /// Si la cible n’est pas encore posée, on éclaire cet élément (souvent l’onglet).
  final GlobalKey? fallbackKey;
  final double borderRadius;
}

List<SpotlightStep> etapesVisiteCliente(ClosetL10n l10n) => [
  SpotlightStep(
    targetKey: ClosetTourKeys.dressing,
    route: '/home',
    title: l10n.navDressing,
    description: l10n.visiteDressing,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.filtres,
    fallbackKey: ClosetTourKeys.collections,
    route: '/collections',
    title: l10n.visiteFiltresTitre,
    description: l10n.visiteFiltres,
    borderRadius: 24,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.wishlist,
    route: '/wishlist',
    title: l10n.navWishlist,
    description: l10n.visiteWishlist,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.selection,
    route: '/selection',
    title: l10n.navSelection,
    description: l10n.visiteSelection,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.commandes,
    fallbackKey: ClosetTourKeys.espace,
    route: '/espace',
    title: l10n.mesCommandes,
    description: l10n.visiteCommandes,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceur,
    fallbackKey: ClosetTourKeys.espace,
    route: '/espace',
    title: l10n.devenirSourceur,
    description: l10n.visiteSourceur,
    borderRadius: 12,
  ),
];

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
  static const _cleFaite = 'closet_visite_guidee_v1';

  @override
  SpotlightTourState build() =>
      const SpotlightTourState(isActive: false, currentStep: 0);

  void startTour({bool pourSourceur = false}) {
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

  void stopTour() {
    HapticFeedback.mediumImpact();
    state = const SpotlightTourState(isActive: false, currentStep: 0);
    _marquerFaite();
  }

  Future<void> _marquerFaite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cleFaite, true);
      ref.invalidate(visiteGuideeFaiteProvider);
    } catch (_) {}
  }
}

final spotlightTourProvider =
    NotifierProvider<SpotlightTourNotifier, SpotlightTourState>(
      SpotlightTourNotifier.new,
    );

final visiteGuideeFaiteProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SpotlightTourNotifier._cleFaite) ?? false;
  } catch (_) {
    return false;
  }
});

class SpotlightPainter extends CustomPainter {
  SpotlightPainter({required this.targetRect, this.borderRadius = 8});

  final Rect targetRect;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final maskPaint = Paint()..color = Colors.black.withValues(alpha: 0.72);
    final fond = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final trou = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(6),
          Radius.circular(borderRadius),
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, fond, trou),
      maskPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter old) =>
      old.targetRect != targetRect || old.borderRadius != borderRadius;
}

/// Overlay de visite. Les coordonnées de la cible sont converties en local
/// (sinon le trou est décalé sous la barre de statut).
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
  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(spotlightTourProvider);
    ref.listen(spotlightTourProvider, (precedent, suivant) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
    if (!tour.isActive || widget.steps.isEmpty) return widget.child;

    final step = widget.steps[tour.currentStep];
    final cible =
        _rectLocal(step.targetKey) ??
        (step.fallbackKey != null ? _rectLocal(step.fallbackKey!) : null);
    final barre = _rectLocal(ClosetTourKeys.barre);
    if (cible == null || barre == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    final taille = MediaQuery.sizeOf(context);
    final margeBas = barre != null ? (taille.height - barre.top + 12) : 96.0;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: cible == null
              ? const ColoredBox(color: Color(0xB8000000))
              : CustomPaint(
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
        Positioned(
          left: 20,
          right: 20,
          bottom: margeBas,
          child: _CarteEtape(
            etape: tour.currentStep,
            total: widget.steps.length,
            titre: step.title,
            description: step.description,
          ),
        ),
      ],
    );
  }

  Rect? _rectLocal(GlobalKey key) {
    final cibleCtx = key.currentContext;
    final box = cibleCtx?.findRenderObject() as RenderBox?;
    final ici = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || ici == null || !ici.hasSize) {
      return null;
    }
    final hautGauche = ici.globalToLocal(box.localToGlobal(Offset.zero));
    return hautGauche & box.size;
  }
}

class _CarteEtape extends ConsumerWidget {
  const _CarteEtape({
    required this.etape,
    required this.total,
    required this.titre,
    required this.description,
  });

  final int etape;
  final int total;
  final String titre;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final derniere = etape == total - 1;
    return Material(
      color: ClosetColors.ivoire,
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.visiteEtape} ${etape + 1} / $total',
                  style: ClosetTextStyles.labelChamp.copyWith(
                    color: ClosetColors.doreEncre,
                    fontSize: 10,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(spotlightTourProvider.notifier).stopTour(),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    l10n.visitePasser,
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
              titre,
              style: ClosetTextStyles.titreEcran.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: ClosetTextStyles.corps.copyWith(
                fontSize: 13,
                height: 1.45,
                color: ClosetColors.noir.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
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
                onPressed: () =>
                    ref.read(spotlightTourProvider.notifier).nextStep(total),
                child: Text(
                  derniere ? l10n.visiteTerminer : l10n.visiteSuivant,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
