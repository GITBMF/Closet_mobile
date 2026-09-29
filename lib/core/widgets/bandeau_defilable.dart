import 'package:flutter/material.dart';

import '../l10n/closet_l10n.dart';
import '../theme/closet_colors.dart';

/// Rangée horizontale : flèches dès que les puces dépassent l’écran.
///
/// Répond à la revue : « navigation horizontale des filtres visible
/// au moyen d’un défilement ou de flèches ».
class BandeauDefilable extends StatefulWidget {
  const BandeauDefilable({
    super.key,
    required this.enfants,
    this.hauteur = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    this.ecart = 8,
    this.pas = 140,
  });

  final List<Widget> enfants;
  final double hauteur;
  final EdgeInsets padding;
  final double ecart;
  final double pas;

  @override
  State<BandeauDefilable> createState() => _BandeauDefilableState();
}

class _BandeauDefilableState extends State<BandeauDefilable> {
  final _scroll = ScrollController();
  var _gauche = false;
  var _droite = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_mettreAJour);
    WidgetsBinding.instance.addPostFrameCallback((_) => _mettreAJour());
  }

  @override
  void didUpdateWidget(covariant BandeauDefilable oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _mettreAJour());
  }

  @override
  void dispose() {
    _scroll.removeListener(_mettreAJour);
    _scroll.dispose();
    super.dispose();
  }

  void _mettreAJour() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final gauche = pos.maxScrollExtent > 4 && pos.pixels > 4;
    final droite = pos.maxScrollExtent > 4 && pos.pixels < pos.maxScrollExtent - 4;
    if (gauche == _gauche && droite == _droite) return;
    setState(() {
      _gauche = gauche;
      _droite = droite;
    });
  }

  Future<void> _glisser(double delta) {
    if (!_scroll.hasClients) return Future<void>.value();
    final cible = (_scroll.offset + delta).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
    return _scroll.animateTo(
      cible,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fond = Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      height: widget.hauteur,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: widget.padding,
            itemCount: widget.enfants.length,
            separatorBuilder: (_, _) => SizedBox(width: widget.ecart),
            itemBuilder: (_, i) => widget.enfants[i],
          ),
          if (_gauche)
            _VoileFleche(
              versLaDroite: false,
              fond: fond,
              onTap: () => _glisser(-widget.pas),
            ),
          if (_droite)
            _VoileFleche(
              versLaDroite: true,
              fond: fond,
              onTap: () => _glisser(widget.pas),
            ),
        ],
      ),
    );
  }
}

class _VoileFleche extends StatelessWidget {
  const _VoileFleche({
    required this.versLaDroite,
    required this.fond,
    required this.onTap,
  });

  final bool versLaDroite;
  final Color fond;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: versLaDroite ? null : 0,
      right: versLaDroite ? 0 : null,
      top: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: versLaDroite ? Alignment.centerRight : Alignment.centerLeft,
            end: versLaDroite ? Alignment.centerLeft : Alignment.centerRight,
            colors: [fond, fond.withValues(alpha: 0)],
          ),
        ),
        child: FlecheBandeau(versLaDroite: versLaDroite, onTap: onTap),
      ),
    );
  }
}

/// Chevron rond utilisé sur les rangées de puces et les onglets de filtres.
class FlecheBandeau extends StatelessWidget {
  const FlecheBandeau({
    super.key,
    required this.versLaDroite,
    required this.onTap,
    this.visible = true,
  });

  final bool versLaDroite;
  final VoidCallback onTap;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final icone = versLaDroite ? Icons.chevron_right : Icons.chevron_left;
    return Opacity(
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: versLaDroite ? l10n.filtresSuivants : l10n.filtresPrecedents,
          onPressed: onTap,
          icon: DecoratedBox(
            decoration: BoxDecoration(
              color: ClosetColors.blanc,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: Icon(icone, size: 20, color: ClosetColors.vert),
          ),
        ),
      ),
    );
  }
}
