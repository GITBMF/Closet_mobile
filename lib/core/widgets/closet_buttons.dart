import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Bouton pilule plein. Vert sapin (ou doré) actif, sauge/beige désactivé.
/// Inclut une micro-interaction d'échelle (scale down) au tap.
class ClosetPrimaryButton extends StatefulWidget {
  const ClosetPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.dore = false,
    this.icone,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Variante dorée (bouton final « Rejoindre le cercle »).
  final bool dore;

  /// Icône optionnelle affichée avant le libellé.
  final IconData? icone;

  @override
  State<ClosetPrimaryButton> createState() => _ClosetPrimaryButtonState();
}

class _ClosetPrimaryButtonState extends State<ClosetPrimaryButton> with SingleTickerProviderStateMixin {
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

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !MediaQuery.disableAnimationsOf(context)) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !MediaQuery.disableAnimationsOf(context)) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final actif = widget.onPressed != null;
    final Color fond;
    final Color texte;
    if (widget.dore) {
      fond = actif ? ClosetColors.dore : ClosetColors.doreDesactive;
      texte = actif ? ClosetColors.noir : ClosetColors.dore;
    } else {
      fond = actif ? ClosetColors.vert : ClosetColors.sauge;
      texte = ClosetColors.texteSurVert;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        height: 54,
        child: Material(
          color: fond,
          borderRadius: BorderRadius.circular(40),
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icone != null) ...[
                      Icon(widget.icone, size: 18, color: texte),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        widget.label.toUpperCase(),
                        textAlign: TextAlign.center,
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
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: const BorderSide(color: ClosetColors.vert, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                label.toUpperCase(),
                style: ClosetTextStyles.bouton
                    .copyWith(color: ClosetColors.vert),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
