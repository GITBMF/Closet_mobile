import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';

/// Plaque CLOS|ET de la maquette (`5:1210` claire, `5:1304` verte).
///
/// Le PNG `logo_fond_vert.png` n’est pas dans le dépôt : le mot-symbole
/// est dessiné ici pour que le splash et l’auth restent lisibles.
class LogoCloset extends StatelessWidget {
  const LogoCloset({
    super.key,
    this.largeur = 232,
    this.hauteur = 132,
    this.variante = VarianteLogo.claire,
  });

  /// Splash : carte blanche, lettres vertes.
  const LogoCloset.splash({super.key})
      : largeur = 232,
        hauteur = 132,
        variante = VarianteLogo.claire;

  /// Auth : plaque verte sur la photo.
  const LogoCloset.auth({super.key})
      : largeur = 148,
        hauteur = 84,
        variante = VarianteLogo.verte;

  final double largeur;
  final double hauteur;
  final VarianteLogo variante;

  @override
  Widget build(BuildContext context) {
    final claire = variante == VarianteLogo.claire;
    return Semantics(
      label: 'ClosET',
      image: true,
      child: Container(
        width: largeur,
        height: hauteur,
        decoration: BoxDecoration(
          color: claire ? ClosetColors.blanc : ClosetColors.vert,
          borderRadius: BorderRadius.circular(hauteur * 0.28),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: largeur * 0.08),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _Motif(
              encre: claire ? ClosetColors.vert : ClosetColors.blanc,
              dore: ClosetColors.doreEncre100,
              taille: hauteur * 0.26,
            ),
          ),
        ),
      ),
    );
  }
}

enum VarianteLogo { claire, verte }

class _Motif extends StatelessWidget {
  const _Motif({
    required this.encre,
    required this.dore,
    required this.taille,
  });

  final Color encre;
  final Color dore;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Boldonse',
      fontSize: taille,
      height: 1,
      color: encre,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('CL', style: style),
        _OCintre(couleur: encre, taille: taille * 1.05),
        Text('S', style: style),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: taille * 0.18),
          child: Container(
            width: 1.5,
            height: taille * 0.95,
            color: dore,
          ),
        ),
        Text('ET', style: style.copyWith(color: dore)),
      ],
    );
  }
}

/// Le O du mot-symbole : cercle + cintre, comme sur `5:1210`.
class _OCintre extends StatelessWidget {
  const _OCintre({required this.couleur, required this.taille});

  final Color couleur;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: taille * 0.92,
      height: taille,
      child: CustomPaint(
        painter: _OCintrePainter(couleur),
      ),
    );
  }
}

class _OCintrePainter extends CustomPainter {
  const _OCintrePainter(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final c = Offset(size.width / 2, size.height * 0.56);
    final r = size.width * 0.34;
    canvas.drawCircle(c, r, paint);

    final crochet = Path()
      ..moveTo(c.dx, c.dy - r * 0.15)
      ..quadraticBezierTo(
        c.dx,
        c.dy - r * 0.72,
        c.dx + r * 0.22,
        c.dy - r * 0.78,
      );
    canvas.drawPath(crochet, paint);

    final barre = Path()
      ..moveTo(c.dx - r * 0.55, c.dy + r * 0.08)
      ..lineTo(c.dx + r * 0.55, c.dy + r * 0.08)
      ..moveTo(c.dx - r * 0.55, c.dy + r * 0.08)
      ..lineTo(c.dx - r * 0.72, c.dy + r * 0.42)
      ..moveTo(c.dx + r * 0.55, c.dy + r * 0.08)
      ..lineTo(c.dx + r * 0.72, c.dy + r * 0.42);
    canvas.drawPath(barre, paint);
  }

  @override
  bool shouldRepaint(covariant _OCintrePainter old) => old.couleur != couleur;
}
