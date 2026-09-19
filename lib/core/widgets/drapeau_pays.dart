import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Drapeau ISO : le Cameroun est peint (l’emoji 🇨🇲 s’affiche en
/// drapeau portugais sur beaucoup d’émulateurs Android).
class DrapeauPays extends StatelessWidget {
  const DrapeauPays({
    super.key,
    required this.iso,
    this.largeur = 22,
    this.hauteur = 16,
  });

  final String iso;
  final double largeur;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    final code = iso.toUpperCase();
    return Semantics(
      label: 'Drapeau $code',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: largeur,
          height: hauteur,
          child: code == 'CM'
              ? const CustomPaint(painter: _DrapeauCameroun())
              : FittedBox(
                  child: Text(
                    _emoji(code),
                    style: const TextStyle(height: 1),
                  ),
                ),
        ),
      ),
    );
  }

  static String _emoji(String iso) {
    return String.fromCharCodes([
      0x1F1E6 + iso.codeUnitAt(0) - 0x41,
      0x1F1E6 + iso.codeUnitAt(1) - 0x41,
    ]);
  }
}

class _DrapeauCameroun extends CustomPainter {
  const _DrapeauCameroun();

  static const _vert = Color(0xFF007A5E);
  static const _rouge = Color(0xFFCE1126);
  static const _jaune = Color(0xFFFCD116);

  @override
  void paint(Canvas canvas, Size size) {
    final bande = size.width / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, bande, size.height), Paint()..color = _vert);
    canvas.drawRect(
      Rect.fromLTWH(bande, 0, bande, size.height),
      Paint()..color = _rouge,
    );
    canvas.drawRect(
      Rect.fromLTWH(bande * 2, 0, bande, size.height),
      Paint()..color = _jaune,
    );

    final centre = Offset(size.width / 2, size.height / 2);
    final externe = size.height * 0.28;
    canvas.drawPath(_etoile(centre, externe, externe * 0.38), Paint()..color = _jaune);
  }

  Path _etoile(Offset centre, double externe, double interne) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? externe : interne;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(
        centre.dx + r * math.cos(a),
        centre.dy + r * math.sin(a),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
