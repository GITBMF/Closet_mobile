import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Définition des clés globales pour cibler les boutons de la démo.
class ClosetTourKeys {
  static final searchKey = GlobalKey();
  static final wishlistKey = GlobalKey();
  static final espaceKey = GlobalKey();
}

/// Étape individuelle de la visite guidée.
class SpotlightStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final double borderRadius;

  const SpotlightStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.borderRadius = 8,
  });
}

/// État de la visite guidée.
class SpotlightTourState {
  final bool isActive;
  final int currentStep;

  SpotlightTourState({required this.isActive, required this.currentStep});

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
    return SpotlightTourState(isActive: false, currentStep: 0);
  }

  void startTour() {
    state = SpotlightTourState(isActive: true, currentStep: 0);
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
    state = SpotlightTourState(isActive: false, currentStep: 0);
  }
}

final spotlightTourProvider =
    NotifierProvider<SpotlightTourNotifier, SpotlightTourState>(() {
  return SpotlightTourNotifier();
});

/// Dessine le masque sombre sur l'écran avec une découpe transparente (spotlight) autour de la cible.
class SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double borderRadius;

  SpotlightPainter({required this.targetRect, this.borderRadius = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.72);

    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect.inflate(6), // Marge autour du bouton
        Radius.circular(borderRadius),
      ));

    final Path finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, maskPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.borderRadius != borderRadius;
  }
}

/// Widget affichant la visite guidée (Spotlight) par-dessus l'application.
class SpotlightShowcase extends ConsumerWidget {
  final Widget child;
  final List<SpotlightStep> steps;

  const SpotlightShowcase({
    super.key,
    required this.child,
    required this.steps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch<SpotlightTourState>(spotlightTourProvider);

    if (!tourState.isActive || steps.isEmpty) {
      return child;
    }

    final step = steps[tourState.currentStep];
    final contextObj = step.targetKey.currentContext;

    if (contextObj == null) {
      return child;
    }

    final renderBox = contextObj.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return child;
    }

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final targetRect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

    final screenSize = MediaQuery.of(context).size;
    // Détermine si le tooltip doit être affiché au-dessus ou en dessous
    final showTooltipBelow = targetRect.center.dy < screenSize.height / 2;

    return Stack(
      children: [
        child,
        // Masque avec spotlight
        Positioned.fill(
          child: CustomPaint(
            painter: SpotlightPainter(
              targetRect: targetRect,
              borderRadius: step.borderRadius,
            ),
          ),
        ),
        // Intercepteur de clics pour empêcher les interactions avec le reste
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Clic en dehors passe à l'étape suivante pour fluidité
              ref.read<SpotlightTourNotifier>(spotlightTourProvider.notifier).nextStep(steps.length);
            },
          ),
        ),
        // Positionnement du Tooltip Premium
        Positioned(
          left: 20,
          right: 20,
          top: showTooltipBelow ? targetRect.bottom + 20 : null,
          bottom: !showTooltipBelow ? (screenSize.height - targetRect.top) + 20 : null,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ClosetColors.ivoire,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ClosetColors.dore,
                width: 1.5,
              ),
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
                    Text(
                      'Étape ${tourState.currentStep + 1} sur ${steps.length}',
                      style: ClosetTextStyles.labelChamp.copyWith(
                        color: ClosetColors.doreEncre,
                        fontSize: 10,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read<SpotlightTourNotifier>(spotlightTourProvider.notifier).stopTour(),
                      child: Text(
                        'PASSER',
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClosetColors.vert,
                        foregroundColor: ClosetColors.creme,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ref.read<SpotlightTourNotifier>(spotlightTourProvider.notifier).nextStep(steps.length);
                      },
                      child: Text(
                        tourState.currentStep == steps.length - 1 ? 'Terminer' : 'Suivant',
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
        ),
      ],
    );
  }
}
