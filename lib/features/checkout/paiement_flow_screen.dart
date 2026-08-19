import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../transaction/recu_screen.dart';
import '../transaction/transaction_models.dart';
import '../transaction/widgets/transaction_scaffold.dart';

class PaiementFlowArgs {
  const PaiementFlowArgs({
    required this.nom,
    required this.telephone,
    required this.moyen,
    required this.montant,
  });

  final String nom;
  final String telephone;
  final String moyen;
  final double montant;
}

/// Tunnel paiement commande — traitement puis confirmation (maquette E2/E3).
class PaiementFlowScreen extends StatefulWidget {
  const PaiementFlowScreen({super.key, this.args});

  final PaiementFlowArgs? args;

  @override
  State<PaiementFlowScreen> createState() => _PaiementFlowScreenState();
}

class _PaiementFlowScreenState extends State<PaiementFlowScreen> {
  bool _succes = false;
  Timer? _timer;

  static const _numeroCommande = 'CE-2641';

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _succes = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  RecuTransaction get _recu {
    final args = widget.args;
    return RecuTransaction(
      demande: DemandeTransaction(
        type: TypeOperation.paiement,
        montant: args?.montant ?? 42000,
        moyen: args?.moyen ?? 'Visa Card',
        compte: '4864',
        beneficiaire: args?.nom ?? 'Aïcha N.',
        note: args?.telephone,
      ),
      numero: _numeroCommande,
      reference: 'CLT-$_numeroCommande',
      horodatage: DateTime.now(),
      piece: const DetailPieceRecu(
        marque: 'Coco Chanel',
        categorie: 'Robe',
        taille: 'M',
        etat: 'Excellente',
        livraison: 'A domicile',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _succes,
      child: Scaffold(
        backgroundColor: ClosetColors.vert,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.p24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
                child: _FriseOr(courante: _succes ? 3 : 2),
              ),
              Expanded(
                child: _succes ? _CorpsSucces(
                  numero: _numeroCommande,
                  onVoirRecu: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecuScreen(
                          recu: _recu,
                          onPartager: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Partage bientôt disponible.'),
                              ),
                            );
                          },
                          onRetour: () => context.go(
                            '/espace/commandes/$_numeroCommande/suivi',
                            extra: true,
                          ),
                        ),
                      ),
                    );
                  },
                  onRetour: () => context.go(
                    '/espace/commandes/$_numeroCommande/suivi',
                    extra: true,
                  ),
                ) : const _CorpsTraitement(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, AppSpacing.p20),
                child: Text(
                  TransactionScaffold.mentionChiffrement,
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.meta.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.22,
                    color: ClosetColors.noteChiffrement,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriseOr extends StatelessWidget {
  const _FriseOr({required this.courante});

  final int courante;

  static const _etapes = ['LIVRAISON', 'PAIEMENT', 'CONFIRMATION'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _etapes.length; i++) ...[
          _PastilleOr(
            numero: i + 1,
            label: _etapes[i],
            active: i + 1 == courante,
          ),
          if (i < _etapes.length - 1)
            Expanded(
              child: Container(
                height: AppStroke.fin,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: ClosetColors.fond300.withValues(alpha: 0.45),
              ),
            ),
        ],
      ],
    );
  }
}

class _PastilleOr extends StatelessWidget {
  const _PastilleOr({
    required this.numero,
    required this.label,
    required this.active,
  });

  final int numero;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? ClosetColors.fond300 : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
          ),
          child: Text(
            '$numero',
            style: ClosetTextStyles.corps.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? ClosetColors.vert : ClosetColors.fond300,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: ClosetTextStyles.microLegende.copyWith(
            letterSpacing: 0.4,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? Colors.white : ClosetColors.fond300,
          ),
        ),
      ],
    );
  }
}

class _CorpsTraitement extends StatelessWidget {
  const _CorpsTraitement();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          const SizedBox(height: 36),
          Text(
            'Traitement en cours',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero.copyWith(
              color: Colors.white,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              'Veuillez patienter quelques instants pendant que nous '
              'sécurisons et validons votre transaction. Merci de ne pas '
              'fermer cette application.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corpsMedium.copyWith(
                fontSize: 14,
                height: 1.45,
                color: ClosetColors.beige,
              ),
            ),
          ),
          const Spacer(),
          const _ArchePaiement(),
          const Spacer(),
          const _SpinnerBlanc(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _ArchePaiement extends StatelessWidget {
  const _ArchePaiement();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 275,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.moyen),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  top: 10,
                  child: Icon(
                    Icons.credit_card_rounded,
                    size: 46,
                    color: ClosetColors.vert.withValues(alpha: 0.55),
                  ),
                ),
                const Positioned(
                  left: 0,
                  top: 0,
                  child: Icon(
                    Icons.credit_card_rounded,
                    size: 46,
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Text(
            'Paiement en cours',
            style: ClosetTextStyles.sousTitre.copyWith(
              fontStyle: FontStyle.italic,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}

class _CorpsSucces extends StatelessWidget {
  const _CorpsSucces({
    required this.numero,
    required this.onVoirRecu,
    required this.onRetour,
  });

  final String numero;
  final VoidCallback onVoirRecu;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          const SizedBox(height: 36),
          Text(
            'Paiement réussi',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero.copyWith(
              color: Colors.white,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.p32),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              size: 44,
              color: ClosetColors.vert,
            ),
          ),
          const SizedBox(height: AppSpacing.p24),
          Text(
            "C'est tout bon !",
            style: ClosetTextStyles.sousTitre.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.p12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Votre pièce sera préparée avec soin et expédiée très prochainement',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corpsMedium.copyWith(
                fontSize: 14,
                height: 1.4,
                color: ClosetColors.beige,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(
            'COMMANDE N° $numero',
            style: ClosetTextStyles.libelle.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: ClosetColors.fond300,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confirmation envoyée sur WhatsApp',
            style: ClosetTextStyles.meta.copyWith(
              color: ClosetColors.noteChiffrement,
            ),
          ),
          const Spacer(),
          BoutonTransaction(label: 'Voir le reçu', onPressed: onVoirRecu),
          const SizedBox(height: AppSpacing.p16),
          BoutonTransaction(
            label: 'Retour dans Mon Espace',
            dore: false,
            onPressed: onRetour,
          ),
          const SizedBox(height: AppSpacing.p12),
        ],
      ),
    );
  }
}

class _SpinnerBlanc extends StatefulWidget {
  const _SpinnerBlanc();

  @override
  State<_SpinnerBlanc> createState() => _SpinnerBlancState();
}

class _SpinnerBlancState extends State<_SpinnerBlanc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _FiletPainter(
              progres: _ctrl.value,
              couleur: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

class _FiletPainter extends CustomPainter {
  const _FiletPainter({required this.progres, required this.couleur});

  final double progres;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    const points = 10;
    final centre = Offset(size.width / 2, size.height / 2);
    final rayon = size.shortestSide / 2 - 4;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < points; i++) {
      final t = (((i / points) - progres) % 1.0 + 1.0) % 1.0;
      final angle = (i / points) * 2 * math.pi - math.pi / 2;
      paint.color = couleur.withValues(alpha: 0.2 + 0.8 * t);
      canvas.drawCircle(
        Offset(
          centre.dx + rayon * math.cos(angle),
          centre.dy + rayon * math.sin(angle),
        ),
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FiletPainter oldDelegate) =>
      oldDelegate.progres != progres || oldDelegate.couleur != couleur;
}
