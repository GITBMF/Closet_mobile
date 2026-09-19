import 'package:flutter/material.dart';

/// Panier à anse dessiné sur une grille de 24 : bord, anse arquée, corps
/// évasé et trois lattes. Remplace l'icône de police, dont le panier était
/// tronqué et se lisait mal dans un petit disque.
class IconePanier extends StatelessWidget {
  const IconePanier({
    super.key,
    required this.taille,
    required this.couleur,
    this.rempli = false,
  });

  final double taille;
  final Color couleur;

  /// Panier plein : le corps est teinté quand la sélection contient des pièces.
  final bool rempli;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: taille,
      height: taille,
      child: CustomPaint(painter: _PeintrePanier(couleur, rempli)),
    );
  }
}

class _PeintrePanier extends CustomPainter {
  const _PeintrePanier(this.couleur, this.rempli);

  final Color couleur;
  final bool rempli;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final trait = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final corps = Path()
      ..moveTo(4.6, 10)
      ..lineTo(6.3, 19.2)
      ..quadraticBezierTo(6.5, 20.2, 7.6, 20.2)
      ..lineTo(16.4, 20.2)
      ..quadraticBezierTo(17.5, 20.2, 17.7, 19.2)
      ..lineTo(19.4, 10)
      ..close();

    if (rempli) {
      canvas.drawPath(
        corps,
        Paint()
          ..color = couleur.withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      );
    }

    // Anse.
    canvas.drawPath(
      Path()
        ..moveTo(8, 9.6)
        ..cubicTo(8, 4.4, 16, 4.4, 16, 9.6),
      trait,
    );
    // Bord.
    canvas.drawLine(const Offset(2.8, 10), const Offset(21.2, 10), trait);
    // Corps évasé.
    canvas.drawPath(corps, trait);
    // Lattes.
    for (final x in const [9.4, 12.0, 14.6]) {
      canvas.drawLine(Offset(x, 13), Offset(x, 17.2), trait);
    }
  }

  @override
  bool shouldRepaint(covariant _PeintrePanier old) =>
      old.couleur != couleur || old.rempli != rempli;
}
