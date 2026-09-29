import 'package:flutter/material.dart';

/// Glissement + fondu à chaque bascule d'onglet, dans le sens du geste (vers
/// l'onglet de droite = arrivée depuis la droite, et inversement).
///
/// Partagé par les shells cliente et sourceur : leur `IndexedStack` interne
/// change instantanément, seul cet habillage anime la transition, sans
/// jamais démonter les branches (leur défilement et leurs formulaires
/// restent intacts).
class ClosetShellTransition extends StatefulWidget {
  const ClosetShellTransition({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<ClosetShellTransition> createState() => _ClosetShellTransitionState();
}

class _ClosetShellTransitionState extends State<ClosetShellTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  late final Animation<double> _fondu = CurvedAnimation(
    parent: _controleur,
    curve: const Interval(0, 0.7, curve: Curves.easeOut),
  );
  late Animation<Offset> _glissement = _construireGlissement(1);
  late int _dernierIndex = widget.index;

  Animation<Offset> _construireGlissement(int sens) {
    return Tween<Offset>(
      begin: Offset(0.035 * sens, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controleur, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant ClosetShellTransition ancien) {
    super.didUpdateWidget(ancien);
    if (widget.index != _dernierIndex) {
      final sens = widget.index > _dernierIndex ? 1 : -1;
      _dernierIndex = widget.index;
      _glissement = _construireGlissement(sens);
      _controleur.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _glissement,
      child: FadeTransition(opacity: _fondu, child: widget.child),
    );
  }
}
