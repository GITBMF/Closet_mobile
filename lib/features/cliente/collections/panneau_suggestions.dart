import 'package:flutter/material.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/recherche/suggestion_recherche.dart';

/// Suggestions sous la barre : repos (populaires + tendances) ou saisie
/// groupée marque → type → taille → état.
class PanneauSuggestionsRecherche extends StatelessWidget {
  const PanneauSuggestionsRecherche({
    super.key,
    required this.panneau,
    required this.onPopulaire,
    required this.onMarqueTendance,
    required this.onSuggestion,
  });

  final PanneauRecherche panneau;
  final ValueChanged<String> onPopulaire;
  final ValueChanged<String> onMarqueTendance;
  final ValueChanged<SuggestionRecherche> onSuggestion;

  @override
  Widget build(BuildContext context) {
    if (panneau.estVide) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.p12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.closetChamp,
          borderRadius: BorderRadius.circular(AppRadius.carte),
          border: Border.all(
            color: ClosetColors.carteBordure,
            width: AppStroke.fin,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.p16,
            AppSpacing.p16,
            AppSpacing.p16,
            AppSpacing.p12,
          ),
          child: panneau.estContextuel
              ? _SuggestionsGroupees(
                  suggestions: panneau.suggestions,
                  onTap: onSuggestion,
                )
              : _Repos(
                  populaires: panneau.recherchesPopulaires,
                  tendances: panneau.marquesTendance,
                  onPopulaire: onPopulaire,
                  onMarque: onMarqueTendance,
                ),
        ),
      ),
    );
  }
}

class _Repos extends StatelessWidget {
  const _Repos({
    required this.populaires,
    required this.tendances,
    required this.onPopulaire,
    required this.onMarque,
  });

  final List<String> populaires;
  final List<String> tendances;
  final ValueChanged<String> onPopulaire;
  final ValueChanged<String> onMarque;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (populaires.isNotEmpty) ...[
          ClosetSurtitre(l10n.recherchesPopulaires),
          const SizedBox(height: AppSpacing.p8),
          _RangPuces(libelles: populaires, onTap: onPopulaire),
        ],
        if (populaires.isNotEmpty && tendances.isNotEmpty)
          const SizedBox(height: AppSpacing.p16),
        if (tendances.isNotEmpty) ...[
          ClosetSurtitre(l10n.marquesTendance),
          const SizedBox(height: AppSpacing.p8),
          _RangPuces(libelles: tendances, onTap: onMarque),
        ],
      ],
    );
  }
}

/// Trois puces par ligne, largeur égale — évite les pilules pleine largeur.
class _RangPuces extends StatelessWidget {
  const _RangPuces({required this.libelles, required this.onTap});

  static const _colonnes = 3;

  final List<String> libelles;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: libelles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _colonnes,
        mainAxisExtent: 36,
        crossAxisSpacing: AppSpacing.p8,
        mainAxisSpacing: AppSpacing.p8,
      ),
      itemBuilder: (context, i) {
        final libelle = libelles[i];
        return _PuceGrille(libelle: libelle, onTap: () => onTap(libelle));
      },
    );
  }
}

class _PuceGrille extends StatelessWidget {
  const _PuceGrille({required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.closetSombre
          ? ClosetColors.emeraude400
          : ClosetColors.carteFond,
      shape: const StadiumBorder(
        side: BorderSide(color: ClosetColors.fond300, width: AppStroke.fin),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
          child: Center(
            child: Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corps.copyWith(
                color: context.closetSombre
                    ? ClosetColors.creme
                    : ClosetColors.chipTexteInactif,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionsGroupees extends StatelessWidget {
  const _SuggestionsGroupees({
    required this.suggestions,
    required this.onTap,
  });

  final List<SuggestionRecherche> suggestions;
  final ValueChanged<SuggestionRecherche> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final groupes = <CategorieSuggestion, List<SuggestionRecherche>>{};
    for (final s in suggestions) {
      groupes.putIfAbsent(s.categorie, () => []).add(s);
    }

    final sections = <Widget>[];
    for (final cat in CategorieSuggestion.values) {
      final lignes = groupes[cat];
      if (lignes == null || lignes.isEmpty) continue;
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: AppSpacing.p12));
      }
      sections.add(ClosetSurtitre(_titre(cat, l10n)));
      sections.add(const SizedBox(height: AppSpacing.p8));
      sections.add(
        _RangPuces(
          libelles: [for (final s in lignes) s.libelle],
          onTap: (libelle) {
            final choisie = lignes.firstWhere((s) => s.libelle == libelle);
            onTap(choisie);
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }

  String _titre(CategorieSuggestion cat, ClosetL10n l10n) => switch (cat) {
        CategorieSuggestion.marque => l10n.suggestionsMarques,
        CategorieSuggestion.type => l10n.suggestionsTypes,
        CategorieSuggestion.taille => l10n.suggestionsTailles,
        CategorieSuggestion.etat => l10n.suggestionsEtats,
      };
}
