import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import 'widgets/transaction_scaffold.dart';

/// Traitement en cours — transcription de la maquette `32:756`.
///
/// Grande icône de cartes, puis spinner pointillé en bas d'écran.
/// L'écran est purement passif : il attend la fin de [operation] et bascule
/// ensuite sur [onTermine] ou [onEchec].
class TraitementScreen extends StatefulWidget {
  const TraitementScreen({
    super.key,
    required this.operation,
    required this.onTermine,
    required this.onEchec,
  });

  /// Traitement réel (appel au backend).
  final Future<void> Function() operation;

  final VoidCallback onTermine;
  final ValueChanged<Object> onEchec;

  @override
  State<TraitementScreen> createState() => _TraitementScreenState();
}

class _TraitementScreenState extends State<TraitementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _lancer());
  }

  Future<void> _lancer() async {
    try {
      await widget.operation();
      if (mounted) widget.onTermine();
    } catch (e) {
      if (mounted) widget.onEchec(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const TransactionScaffold(
      titre: 'Traitement en cours',
      child: Column(
        children: [
          SizedBox(height: 48),
          TexteTransaction(
            'Veuillez patienter quelques instants pendant que nous '
            'sécurisons et validons votre transaction. Merci de ne pas '
            'fermer cette application.',
          ),
          SizedBox(height: 72),
          _IconeCartes(),
          Spacer(),
          _SpinnerPointille(),
          SizedBox(height: 34),
        ],
      ),
    );
  }
}

class _IconeCartes extends StatelessWidget {
  const _IconeCartes();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 86,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: Transform.rotate(
              angle: -0.18,
              child: const _CarteSilhouette(),
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: _CarteSilhouette(),
          ),
        ],
      ),
    );
  }
}

class _CarteSilhouette extends StatelessWidget {
  const _CarteSilhouette();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Align(
        alignment: Alignment(-0.55, 0.2),
        child: SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerPointille extends StatefulWidget {
  const _SpinnerPointille();

  @override
  State<_SpinnerPointille> createState() => _SpinnerPointilleState();
}

class _SpinnerPointilleState extends State<_SpinnerPointille>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: const Size(42, 42),
        painter: const _PointsPainter(),
      ),
    );
  }
}

class _PointsPainter extends CustomPainter {
  const _PointsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const n = 10;
    final r = size.width / 2 - 3;
    for (var i = 0; i < n; i++) {
      final a = (i / n) * math.pi * 2 - math.pi / 2;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25 + (i / n) * 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        2.4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Écran de succès — transcription de la maquette `32:813`.
///
/// Carte blanche en arche, sceau « C'est tout bon ! », puis deux boutons.
class SuccesScreen extends StatelessWidget {
  const SuccesScreen({
    super.key,
    required this.onVoirRecu,
    required this.onRetour,
  });

  final VoidCallback onVoirRecu;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      titre: 'Transaction reussie !',
      child: Column(
        children: [
          const SizedBox(height: 28),
          const _ArcheSucces(),
          const SizedBox(height: AppSpacing.p24),
          const TexteTransaction(
            'Votre opération a été effectuée avec succès. Vous allez '
            'recevoir un reçu de confirmation d’ici quelques instants.',
          ),
          const Spacer(),
          BoutonTransaction(label: 'Voir le reçu', onPressed: onVoirRecu),
          const SizedBox(height: AppSpacing.p16),
          BoutonTransaction(
            label: 'Retour dans Mon Espace',
            dore: false,
            onPressed: onRetour,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _ArcheSucces extends StatelessWidget {
  const _ArcheSucces();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 248,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      decoration: BoxDecoration(
        color: ClosetColors.beige,
        border: Border.all(color: ClosetColors.fond300),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 28, color: Colors.white),
                SizedBox(height: 4),
                _BarreBlanche(),
                SizedBox(height: 3),
                _BarreBlanche(largeur: 18),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'C’est tout bon !',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreBloc.copyWith(
              fontFamily: ClosetTextStyles.prix.fontFamily,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarreBlanche extends StatelessWidget {
  const _BarreBlanche({this.largeur = 26});

  final double largeur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largeur,
      height: 2,
      color: Colors.white.withValues(alpha: 0.85),
    );
  }
}
