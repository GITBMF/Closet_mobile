import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/closet_l10n.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Cibles de la visite — posées sur la barre cliente, toujours à l’écran.
class ClosetTourKeys {
  static final dressing = GlobalKey();
  static final collections = GlobalKey();
  static final wishlist = GlobalKey();
  static final selection = GlobalKey();
  static final espace = GlobalKey();
  static final barre = GlobalKey();
}

class SpotlightStep {
  const SpotlightStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.borderRadius = 20,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;
  final double borderRadius;
}

List<SpotlightStep> etapesVisiteCliente(ClosetL10n l10n) => [
      SpotlightStep(
        targetKey: ClosetTourKeys.dressing,
        title: l10n.navDressing,
        description: l10n.visiteDressing,
      ),
      SpotlightStep(
        targetKey: ClosetTourKeys.collections,
        title: l10n.navCollections,
        description: l10n.visiteCollections,
      ),
      SpotlightStep(
        targetKey: ClosetTourKeys.wishlist,
        title: l10n.navWishlist,
        description: l10n.visiteWishlist,
      ),
      SpotlightStep(
        targetKey: ClosetTourKeys.selection,
        title: l10n.navSelection,
        description: l10n.visiteSelection,
      ),
      SpotlightStep(
        targetKey: ClosetTourKeys.espace,
        title: l10n.navEspace,
        description: l10n.visiteEspace,
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
  @override
  SpotlightTourState build() =>
      const SpotlightTourState(isActive: false, currentStep: 0);

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

  void stopTour() {
    HapticFeedback.mediumImpact();
    state = const SpotlightTourState(isActive: false, currentStep: 0);
  }
}

final spotlightTourProvider =
    NotifierProvider<SpotlightTourNotifier, SpotlightTourState>(
  SpotlightTourNotifier.new,
);

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
    final cible = _rectLocal(step.targetKey);
    final barre = _rectLocal(ClosetTourKeys.barre);
    if (cible == null || barre == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    final taille = MediaQuery.sizeOf(context);
    final margeBas = barre != null
        ? (taille.height - barre.top + 12)
        : 96.0;

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
                GestureDetector(
                  onTap: () =>
                      ref.read(spotlightTourProvider.notifier).stopTour(),
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
            Text(titre, style: ClosetTextStyles.titreEcran.copyWith(fontSize: 18)),
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
                onPressed: () => ref
                    .read(spotlightTourProvider.notifier)
                    .nextStep(total),
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
