import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';

/// Écran d'ouverture — transcription de la maquette Figma `5:1210`.
///
/// Photo de dressing en fond plein cadre, carte verte au logo centrée
/// (232 × 132), et anneau de points en rotation dans le bas de l'écran.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _apparition;
  late final AnimationController _rotation;
  late final Animation<double> _fondu;
  late final Animation<double> _echelle;

  @override
  void initState() {
    super.initState();

    _apparition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fondu = CurvedAnimation(parent: _apparition, curve: Curves.easeIn);
    _echelle = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _apparition, curve: Curves.easeOutCubic),
    );

    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _apparition.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _apparition.dispose();
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash_background.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: ClosetColors.vert),
          ),
          Center(
            child: FadeTransition(
              opacity: _fondu,
              child: ScaleTransition(
                scale: _echelle,
                child: Image.asset(
                  'assets/logo_fond_vert.png',
                  width: 232,
                  height: 132,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 232,
                    height: 132,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.68),
            child: FadeTransition(
              opacity: _fondu,
              child: _AnneauDePoints(animation: _rotation),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loader de la maquette : douze points blancs en cercle, dont l'opacité
/// tourne. 28 × 28 comme dans le Figma.
class _AnneauDePoints extends StatelessWidget {
  const _AnneauDePoints({required this.animation});

  final Animation<double> animation;

  static const int _nombreDePoints = 12;
  static const double _taille = 28;
  static const double _rayonPoint = 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _taille,
      height: _taille,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            children: [
              for (var i = 0; i < _nombreDePoints; i++)
                _point(i, animation.value),
            ],
          );
        },
      ),
    );
  }

  Widget _point(int index, double avancement) {
    const rayonAnneau = _taille / 2 - _rayonPoint;
    final angle = 2 * math.pi * index / _nombreDePoints - math.pi / 2;
    final dx = _taille / 2 + rayonAnneau * math.cos(angle) - _rayonPoint;
    final dy = _taille / 2 + rayonAnneau * math.sin(angle) - _rayonPoint;

    // Le point « en tête » est opaque, les suivants s'estompent.
    final decalage = (index / _nombreDePoints - avancement) % 1.0;
    final opacite = 0.2 + 0.8 * (1 - decalage);

    return Positioned(
      left: dx,
      top: dy,
      child: Opacity(
        opacity: opacite.clamp(0.0, 1.0),
        child: Container(
          width: _rayonPoint * 2,
          height: _rayonPoint * 2,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
