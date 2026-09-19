import 'package:flutter/material.dart';

/// Badge de marque pour Visa, MTN et Orange — revue Ahmed : les lignes
/// de paiement ne doivent plus n’afficher qu’un pictogramme téléphone.
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

  static _Palette _palette(String id) {
    final cle = id.toLowerCase();
    if (cle.contains('orange')) {
      return const _Palette(
        fond: Color(0xFFFF7900),
        encre: Color(0xFFFFFFFF),
        mot: 'orange',
        libelle: 'Orange Money',
      );
    }
    if (cle.contains('mtn')) {
      return const _Palette(
        fond: Color(0xFFFFCC00),
        encre: Color(0xFF000000),
        mot: 'MTN',
        libelle: 'MTN Mobile Money',
      );
    }
    return const _Palette(
      fond: Color(0xFF1A1F71),
      encre: Color(0xFFFFFFFF),
      mot: 'VISA',
      libelle: 'Visa',
      italique: true,
      filet: Color(0xFFF9A01B),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(id);
    return Semantics(
      label: palette.libelle,
      image: true,
      child: SizedBox(
        width: largeur,
        height: hauteur,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.fond,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  palette.mot,
                  style: TextStyle(
                    color: palette.encre,
                    fontSize: hauteur * 0.42,
                    fontWeight: FontWeight.w800,
                    fontStyle:
                        palette.italique ? FontStyle.italic : FontStyle.normal,
                    letterSpacing: palette.italique ? 0.8 : 0.2,
                    height: 1,
                  ),
                ),
              ),
              if (palette.filet != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.fromLTRB(4, 0, 4, 3),
                    decoration: BoxDecoration(
                      color: palette.filet,
                      borderRadius: BorderRadius.circular(1),
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

class _Palette {
  const _Palette({
    required this.fond,
    required this.encre,
    required this.mot,
    required this.libelle,
    this.italique = false,
    this.filet,
  });

  final Color fond;
  final Color encre;
  final String mot;
  final String libelle;
  final bool italique;
  final Color? filet;
}
