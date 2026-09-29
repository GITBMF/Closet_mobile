import 'package:flutter/material.dart';

import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import '../validation/formats.dart';

/// Rappel des règles du mot de passe + barre de force, mis à jour à la saisie.
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
    final neutre = surFondSombre ? ClosetColors.beige : ClosetColors.taupe;
    final ok = surFondSombre ? ClosetColors.fond300 : ClosetColors.vert;
    final l10n = ClosetL10n.of(context);
    final score = [
      etat.longueur,
      etat.lettre,
      etat.chiffre,
      etat.sansEspace,
    ].where((v) => v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BarreForce(
          score: saisie.isEmpty ? 0 : score,
          libelle: _libelleForce(l10n, saisie, score),
          neutre: neutre,
        ),
        const SizedBox(height: AppSpacing.p12),
        _Ligne(
          ok: etat.longueur,
          texte: l10n.regle8CaracteresMinimum,
          neutre: neutre,
          okColor: ok,
        ),
        _Ligne(
          ok: etat.lettre,
          texte: l10n.regleAuMoinsUneLettre,
          neutre: neutre,
          okColor: ok,
        ),
        _Ligne(
          ok: etat.chiffre,
          texte: l10n.regleAuMoinsUnChiffre,
          neutre: neutre,
          okColor: ok,
        ),
        _Ligne(
          ok: etat.sansEspace,
          texte: l10n.regleSansEspace,
          neutre: neutre,
          okColor: ok,
        ),
      ],
    );
  }

  static String _libelleForce(ClosetL10n l10n, String saisie, int score) {
    if (saisie.isEmpty) return l10n.forceMdpVide;
    return switch (score) {
      0 || 1 => l10n.forceMdpFaible,
      2 => l10n.forceMdpMoyen,
      3 => l10n.forceMdpFort,
      _ => l10n.forceMdpExcellent,
    };
  }
}

/// 4 segments — un par règle validée — colorés du rouge au vert selon
/// le nombre de règles déjà satisfaites.
class _BarreForce extends StatelessWidget {
  const _BarreForce({
    required this.score,
    required this.libelle,
    required this.neutre,
  });

  final int score;
  final String libelle;
  final Color neutre;

  static const _segments = 4;

  Color get _couleur => switch (score) {
        0 || 1 => ClosetColors.erreurCouture,
        2 => ClosetColors.alerte,
        3 => ClosetColors.doreEncre,
        _ => ClosetColors.succes,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _segments; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < score
                        ? _couleur
                        : neutre.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          libelle,
          style: ClosetTextStyles.corpsMedium.copyWith(
            color: score == 0 ? neutre : _couleur,
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: ok ? okColor : neutre,
          ),
          const SizedBox(width: 6),
          Text(
            texte,
            style: ClosetTextStyles.libelle.copyWith(
              color: ok ? okColor : neutre,
            ),
          ),
        ],
      ),
    );
  }
}
