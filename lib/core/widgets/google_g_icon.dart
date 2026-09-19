import 'package:flutter/material.dart';

/// « G » officiel Google (bleu / rouge / jaune / vert), 4 couleurs de la
/// charte Identity — pas l’icône Material `g_mobiledata`.
class GoogleGIcon extends StatelessWidget {
  const GoogleGIcon({super.key, this.taille = 18});

  final double taille;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: taille,
      height: taille,
      child: const CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _bleu = Color(0xFF4285F4);
  static const _vert = Color(0xFF34A853);
  static const _jaune = Color(0xFFFBBC05);
  static const _rouge = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.scale(s / 24, s / 24);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt;

    stroke.color = _bleu;
    canvas.drawArc(
      const Rect.fromLTWH(2, 2, 20, 20),
      -0.35,
      1.55,
      false,
      stroke,
    );

    stroke.color = _vert;
    canvas.drawArc(
      const Rect.fromLTWH(2, 2, 20, 20),
      1.15,
      1.25,
      false,
      stroke,
    );

    stroke.color = _jaune;
    canvas.drawArc(
      const Rect.fromLTWH(2, 2, 20, 20),
      2.35,
      0.95,
      false,
      stroke,
    );

    stroke.color = _rouge;
    canvas.drawArc(
      const Rect.fromLTWH(2, 2, 20, 20),
      3.25,
      1.35,
      false,
      stroke,
    );

    canvas.drawRect(
      const Rect.fromLTWH(11, 10.6, 11, 2.8),
      Paint()..color = _bleu,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
