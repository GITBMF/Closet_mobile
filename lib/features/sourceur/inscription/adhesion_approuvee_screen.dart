import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../transaction/widgets/transaction_scaffold.dart';

/// Adhésion approuvée — transcription de la maquette `29:46`.
///
/// Arche blanche portant le sceau coquillé et « Vérification approuvée ! »,
/// félicitations en EB Garamond, mention WhatsApp, puis deux sorties.
class AdhesionApprouveeScreen extends ConsumerWidget {
  const AdhesionApprouveeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      // L'adhésion est actée côté serveur : revenir en arrière renverrait sur
      // un écran de suivi devenu faux.
      canPop: false,
      child: Scaffold(
        backgroundColor: ClosetColors.vert,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _ArcheValidation(),
                const SizedBox(height: AppSpacing.p32),
                Text(
                  'Félicitation votre adhésion a été approuvée avec succès !',
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.titreHero.copyWith(
                    fontSize: 24,
                    letterSpacing: 0.3,
                    height: 1.25,
                    color: ClosetColors.beige,
                  ),
                ),
                const SizedBox(height: AppSpacing.p16),
                Text(
                  'Votre pièce sera préparée avec soin et expédiée très '
                  'prochainement.',
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.corps.copyWith(
                    fontSize: 13,
                    height: 1.45,
                    color: ClosetColors.neutre300,
                  ),
                ),
                const SizedBox(height: AppSpacing.p12),
                Text(
                  'Confirmation envoyée sur WhatsApp',
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.meta.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.2,
                    color: ClosetColors.neutre400,
                  ),
                ),
                const Spacer(flex: 3),
                BoutonTransaction(
                  label: 'Entrer dans mon espace sourceur',
                  onPressed: () {
                    ref.read(sourceurRepositoryProvider).validerAdhesion();
                    context.go('/sourceur/espace');
                  },
                ),
                const SizedBox(height: AppSpacing.p16),
                BoutonTransaction(
                  label: 'Poursuivre ma visite',
                  dore: false,
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Arche blanche 217 × 275 cerclée d'or, sceau coquillé et mention.
class _ArcheValidation extends StatelessWidget {
  const _ArcheValidation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 275,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        40,
        AppSpacing.p20,
        AppSpacing.p24,
      ),
      decoration: BoxDecoration(
        color: ClosetColors.beige,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        children: [
          const _SceauApprouve(),
          const Spacer(),
          Text(
            'Vérification approuvée !',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreBloc.copyWith(
              fontFamily: ClosetTextStyles.prix.fontFamily,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cercle coquillé vert profond, coche blanche au centre.
class _SceauApprouve extends StatelessWidget {
  const _SceauApprouve();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(
        painter: _CoquillePainter(color: ClosetColors.vert),
        child: Center(
          child: Icon(
            Icons.check,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CoquillePainter extends CustomPainter {
  const _CoquillePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const bosses = 12;
    final rayon = size.width / 2 * 0.78;
    final bosse = size.width / 2 * 0.22;
    final path = Path();

    for (var i = 0; i < bosses; i++) {
      final a0 = (i / bosses) * math.pi * 2 - math.pi / 2;
      final a1 = ((i + 1) / bosses) * math.pi * 2 - math.pi / 2;
      final mid = (a0 + a1) / 2;
      final debut = Offset(cx + rayon * math.cos(a0), cy + rayon * math.sin(a0));
      final controle = Offset(
        cx + (rayon + bosse) * math.cos(mid),
        cy + (rayon + bosse) * math.sin(mid),
      );
      final fin = Offset(cx + rayon * math.cos(a1), cy + rayon * math.sin(a1));
      if (i == 0) path.moveTo(debut.dx, debut.dy);
      path.quadraticBezierTo(controle.dx, controle.dy, fin.dx, fin.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CoquillePainter oldDelegate) => oldDelegate.color != color;
}
