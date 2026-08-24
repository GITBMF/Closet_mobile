import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import '../validation/formats.dart';

/// Rappel des règles du mot de passe, mis à jour à la saisie.
class AideMotDePasse extends StatelessWidget {
  const AideMotDePasse({
    super.key,
    required this.saisie,
    this.surFondSombre = false,
  });

  final String saisie;
  final bool surFondSombre;

  @override
  Widget build(BuildContext context) {
    final etat = EtatMotDePasse.de(saisie);
    final neutre =
        surFondSombre ? ClosetColors.beige : ClosetColors.taupe;
    final ok = surFondSombre ? ClosetColors.fond300 : ClosetColors.vert;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Ligne(ok: etat.longueur, texte: '8 caractères minimum', neutre: neutre, okColor: ok),
        _Ligne(ok: etat.lettre, texte: 'Au moins une lettre', neutre: neutre, okColor: ok),
        _Ligne(ok: etat.chiffre, texte: 'Au moins un chiffre', neutre: neutre, okColor: ok),
        _Ligne(ok: etat.sansEspace, texte: 'Sans espace', neutre: neutre, okColor: ok),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.ok,
    required this.texte,
    required this.neutre,
    required this.okColor,
  });

  final bool ok;
  final String texte;
  final Color neutre;
  final Color okColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '${ok ? '✓' : '·'} $texte',
        style: ClosetTextStyles.meta.copyWith(
          fontWeight: FontWeight.w300,
          color: ok ? okColor : neutre,
        ),
      ),
    );
  }
}
