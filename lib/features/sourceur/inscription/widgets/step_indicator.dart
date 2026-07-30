import 'package:flutter/material.dart';

import '../../../../core/theme/closet_colors.dart';
import '../../../../core/theme/closet_text_styles.dart';

/// Indicateur des 3 étapes du parcours (Atelier, Univers, Paiement).
/// Étape courante : vert sapin. Étapes validées : doré. À venir : crème.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.etapeCourante,
    required this.labels,
  });

  /// Index (base 0) de l'étape courante.
  final int etapeCourante;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      children.add(_Etape(
        numero: i + 1,
        label: labels[i],
        etat: i == etapeCourante
            ? _EtatEtape.courante
            : i < etapeCourante
                ? _EtatEtape.validee
                : _EtatEtape.aVenir,
      ));
      if (i < labels.length - 1) {
        children.add(Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 26, left: 8, right: 8),
            color: i < etapeCourante
                ? ClosetColors.dore
                : ClosetColors.bordure,
          ),
        ));
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: children);
  }
}

enum _EtatEtape { validee, courante, aVenir }

class _Etape extends StatelessWidget {
  const _Etape({
    required this.numero,
    required this.label,
    required this.etat,
  });

  final int numero;
  final String label;
  final _EtatEtape etat;

  @override
  Widget build(BuildContext context) {
    final (fond, texte, bordure) = switch (etat) {
      _EtatEtape.courante => (
          ClosetColors.vert,
          ClosetColors.texteSurVert,
          ClosetColors.vert,
        ),
      _EtatEtape.validee => (
          ClosetColors.dore,
          ClosetColors.noir,
          ClosetColors.dore,
        ),
      _EtatEtape.aVenir => (
          ClosetColors.creme,
          ClosetColors.noir,
          ClosetColors.bordure,
        ),
    };
    final taille = etat == _EtatEtape.courante ? 36.0 : 30.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: taille,
          height: taille,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fond,
            shape: BoxShape.circle,
            border: Border.all(color: bordure, width: 1),
          ),
          child: Text(
            '$numero',
            style: ClosetTextStyles.numeroEtape.copyWith(color: texte),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: ClosetTextStyles.labelEtape),
      ],
    );
  }
}
