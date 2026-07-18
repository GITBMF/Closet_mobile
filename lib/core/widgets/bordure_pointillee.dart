import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';

/// Encadre son enfant d'une bordure arrondie en pointillés
/// (états vides, emplacements de photos...).
class BordurePointillee extends StatelessWidget {
  const BordurePointillee({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.couleur = ClosetColors.bordure,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BordurePointilleePainter(
        couleur: couleur,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _BordurePointilleePainter extends CustomPainter {
  const _BordurePointilleePainter({
    required this.couleur,
    required this.borderRadius,
  });

  final Color couleur;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()..addRRect(borderRadius.toRRect(Offset.zero & size));

    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_BordurePointilleePainter oldDelegate) =>
      couleur != oldDelegate.couleur ||
      borderRadius != oldDelegate.borderRadius;
}
