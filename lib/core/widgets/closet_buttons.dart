import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Hauteur du CTA principal dans la maquette (`11:30` — « Découvrir »).
///
/// ⚠️ 34 px est en dessous des 44 px recommandés pour une cible tactile.
/// Valeur transcrite telle quelle par fidélité ; passer `hauteur:
/// AppSpacing.minTouchTarget` sur les boutons critiques si besoin.
const double _hauteurCta = 34;

/// Bouton pilule plein. Vert profond par défaut, doré en variante.
/// Inclut une micro-interaction d'échelle au tap.
class ClosetPrimaryButton extends StatefulWidget {
  const ClosetPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.dore = false,
    this.icone,
    this.hauteur = _hauteurCta,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Variante dorée — c'est le CTA principal de la maquette (fond `#CDAB71`).
  final bool dore;

  /// Icône optionnelle affichée avant le libellé.
  final IconData? icone;

  /// Hauteur du bouton. Par défaut celle de la maquette.
  final double hauteur;

  @override
  State<ClosetPrimaryButton> createState() => _ClosetPrimaryButtonState();
}

class _ClosetPrimaryButtonState extends State<ClosetPrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _animable =>
      widget.onPressed != null && !MediaQuery.disableAnimationsOf(context);

  void _onTapDown(TapDownDetails details) {
    if (_animable) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_animable) _controller.reverse();
  }

  void _onTapCancel() {
    if (_animable) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final actif = widget.onPressed != null;
    final Color fond;
    final Color texte;
    if (widget.dore) {
      fond = actif ? ClosetColors.fond300 : ClosetColors.doreDesactive;
      texte = actif ? ClosetColors.noir : ClosetColors.doreEncre;
    } else {
      fond = actif ? ClosetColors.vert : ClosetColors.sauge;
      texte = ClosetColors.texteSurVert;
    }

    final rayon = BorderRadius.circular(AppRadius.cercle);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        height: widget.hauteur,
        child: Material(
          color: fond,
          borderRadius: rayon,
          child: InkWell(
            borderRadius: rayon,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icone != null) ...[
                      Icon(widget.icone, size: 16, color: texte),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: ClosetTextStyles.bouton.copyWith(color: texte),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton pilule contour (« Retour »).
class ClosetOutlineButton extends StatelessWidget {
  const ClosetOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.hauteur = _hauteurCta,
  });

  final String label;
  final VoidCallback? onPressed;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);

    return SizedBox(
      height: hauteur,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: rayon,
          side: const BorderSide(
            color: ClosetColors.vert,
            width: AppStroke.moyen,
          ),
        ),
        child: InkWell(
          borderRadius: rayon,
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style:
                    ClosetTextStyles.bouton.copyWith(color: ClosetColors.vert),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
