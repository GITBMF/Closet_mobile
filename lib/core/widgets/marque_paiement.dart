import 'package:flutter/material.dart';

/// Logo officiel de Visa, MTN ou Orange devant une ligne de paiement.
class MarquePaiement extends StatelessWidget {
  const MarquePaiement({
    super.key,
    required this.id,
    this.largeur = 40,
    this.hauteur = 24,
  });

  /// `orange_money` / `orange`, `mtn_momo` / `mtn`, `visa`.
  final String id;
  final double largeur;
  final double hauteur;

  static _Marque _marque(String id) {
    final cle = id.toLowerCase();
    if (cle.contains('orange')) {
      return const _Marque(
        asset: 'assets/orange.png',
        fond: Color(0xFFFF6600),
        libelle: 'Orange Money',
      );
    }
    if (cle.contains('mtn')) {
      return const _Marque(
        asset: 'assets/mtn.png',
        fond: Color(0xFFFFCC00),
        libelle: 'MTN Mobile Money',
      );
    }
    return const _Marque(
      asset: 'assets/visa.png',
      fond: Color(0xFFFFFFFF),
      libelle: 'Visa',
      marge: 4,
      cadre: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final marque = _marque(id);
    return Semantics(
      label: marque.libelle,
      image: true,
      child: SizedBox(
        width: largeur,
        height: hauteur,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: marque.fond,
            borderRadius: BorderRadius.circular(4),
            border: marque.cadre
                ? Border.all(color: const Color(0xFFE2E2E2), width: 0.5)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: marque.marge * 1.5,
                vertical: marque.marge,
              ),
              child: Image.asset(
                marque.asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Marque {
  const _Marque({
    required this.asset,
    required this.fond,
    required this.libelle,
    this.marge = 0,
    this.cadre = false,
  });

  final String asset;
  final Color fond;
  final String libelle;
  final double marge;
  final bool cadre;
}
