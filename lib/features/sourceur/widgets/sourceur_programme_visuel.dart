import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

/// Plaque blanche « CLOS ET / SOURCING PROGRAM » posée sur les visuels
/// d'entrée du programme sourceur.
class SourceurBadgeProgramme extends StatelessWidget {
  const SourceurBadgeProgramme({super.key, this.largeur = 220});

  final double largeur;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: largeur),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WordmarkClosEt(),
          SizedBox(height: 10),
          _LibelleSourcing(),
        ],
      ),
    );
  }
}

/// Wordmark CLOS | ET — Lato extra-gras, cintre doré au-dessus.
class _WordmarkClosEt extends StatelessWidget {
  const _WordmarkClosEt();

  @override
  Widget build(BuildContext context) {
    final clos = ClosetTextStyles.libelleFort.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.4,
      height: 1,
      color: ClosetColors.noir,
    );
    final et = clos.copyWith(color: ClosetColors.fond300);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(36, 16),
          painter: _CintrePainter(color: ClosetColors.fond300),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('CLOS', style: clos),
            Container(
              width: 2,
              height: 26,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: ClosetColors.fond300,
            ),
            Text('ET', style: et),
          ],
        ),
      ],
    );
  }
}

class _LibelleSourcing extends StatelessWidget {
  const _LibelleSourcing();

  @override
  Widget build(BuildContext context) {
    return Text(
      'SOURCING PROGRAM',
      textAlign: TextAlign.center,
      style: ClosetTextStyles.libelleFort.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        height: 1.2,
        color: ClosetColors.noir,
      ),
    );
  }
}

/// Cintre doré du wordmark — filet simple, crochet au centre.
class _CintrePainter extends CustomPainter {
  const _CintrePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final hang = Path()
      ..moveTo(size.width * 0.08, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * -0.15,
        size.width * 0.92,
        size.height * 0.92,
      );
    canvas.drawPath(hang, paint);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.28),
      2.2,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_CintrePainter oldDelegate) => oldDelegate.color != color;
}

/// Photo dressing en arche, coiffée du badge programme.
class SourceurVisuelArche extends StatelessWidget {
  const SourceurVisuelArche({
    super.key,
    this.largeur = 236,
    this.hauteur = 268,
  });

  final double largeur;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largeur,
      height: hauteur,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(159),
            ),
            child: Image.asset(
              'assets/onboarding_1.jpg',
              width: largeur,
              height: hauteur,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: ClosetColors.emeraude400,
                child: SizedBox(width: largeur, height: hauteur),
              ),
            ),
          ),
          const SourceurBadgeProgramme(),
        ],
      ),
    );
  }
}

/// Photo dressing en carte arrondie, coiffée du badge programme.
class SourceurVisuelCarte extends StatelessWidget {
  const SourceurVisuelCarte({super.key, this.hauteur = 188});

  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: hauteur,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: SizedBox.expand(
              child: Image.asset(
                'assets/onboarding_1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: ClosetColors.emeraude400),
              ),
            ),
          ),
          const SourceurBadgeProgramme(),
        ],
      ),
    );
  }
}
