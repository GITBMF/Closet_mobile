import 'package:flutter/material.dart';

/// Léger tassement au toucher (0.97×), relâché en rebond doux — la même
/// signature tactile que les boutons de l'app, appliquée aux cartes : le
/// tap se sent avant même que l'écran suivant s'ouvre.
class ClosetPressable extends StatefulWidget {
  const ClosetPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  State<ClosetPressable> createState() => _ClosetPressableState();
}

class _ClosetPressableState extends State<ClosetPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    value: 1,
  );
  late final Animation<double> _echelle = Tween<double>(begin: 0.97, end: 1)
      .animate(CurvedAnimation(parent: _controleur, curve: Curves.easeOut));

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  bool get _animable => widget.onTap != null;

  void _presser(_) {
    if (_animable) _controleur.reverse();
  }

  void _relacher([_]) {
    if (_animable) _controleur.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _presser,
      onTapUp: _relacher,
      onTapCancel: _relacher,
      child: ScaleTransition(scale: _echelle, child: widget.child),
    );
  }
}
