import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_filet.dart';

/// Champ du formulaire de livraison : libellé vert, zone blanche cerclée d'or.
///
/// Gabarit de `56:11462`, réemployé par les variantes de saisie d'adresse
/// (`162:3844`) et de carte bancaire (`162:5427`).
class ChampCheckout extends StatelessWidget {
  const ChampCheckout({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ClosetTextStyles.labelChamp.copyWith(
            fontWeight: FontWeight.w500,
            color: ClosetColors.vert,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
          cursorColor: ClosetColors.vert,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: ClosetTextStyles.saisie.copyWith(
              color: ClosetColors.placeholderGris,
            ),
            filled: true,
            fillColor: context.closetChamp,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p16,
              vertical: AppSpacing.p12,
            ),
            border: bordureChamp(ClosetColors.fond300),
            enabledBorder: bordureChamp(ClosetColors.fond300),
            focusedBorder: bordureChamp(ClosetColors.vert),
            errorBorder: bordureChamp(ClosetColors.erreurCouture),
            focusedErrorBorder: bordureChamp(ClosetColors.erreurCouture),
          ),
        ),
      ],
    );
  }
}

OutlineInputBorder bordureChamp(Color couleur) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.carte),
      borderSide: BorderSide(color: couleur, width: AppStroke.fin),
    );

/// Champ non saisissable qui ouvre un sélecteur — région, département, ville.
///
/// La maquette les dessine comme des champs (`162:3709`), pas comme des menus
/// déroulants système : même bordure, même hauteur, chevron à droite.
class ChampSelecteur extends StatelessWidget {
  const ChampSelecteur({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.valeur,
    this.sousTexte,
    this.actif = true,
  });

  final String label;
  final String placeholder;

  /// Valeur retenue. Nulle = rien de choisi, le placeholder s'affiche.
  final String? valeur;

  /// Précision affichée sous le champ (« Livraison à domicile 24h-48h »).
  final String? sousTexte;

  /// Désactivé tant que le niveau précédent de la cascade n'est pas choisi.
  final bool actif;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rempli = valeur != null && valeur!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ClosetTextStyles.labelChamp.copyWith(
            fontWeight: FontWeight.w500,
            color: actif ? ClosetColors.vert : ClosetColors.taupe,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        Semantics(
          button: true,
          enabled: actif,
          label: label,
          value: valeur,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.carte),
            onTap: actif ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: actif ? context.closetChamp : context.closetFond,
                borderRadius: BorderRadius.circular(AppRadius.carte),
                border: Border.all(
                  color: ClosetColors.fond300,
                  width: AppStroke.fin,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rempli ? valeur! : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ClosetTextStyles.saisie.copyWith(
                        color: rempli
                            ? context.closetEncre
                            : ClosetColors.placeholderGris,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: actif ? ClosetColors.vert : ClosetColors.ligne,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (sousTexte != null) ...[
          const SizedBox(height: AppSpacing.p8),
          Text(
            sousTexte!,
            style: ClosetTextStyles.meta.copyWith(color: ClosetColors.taupe),
          ),
        ],
      ],
    );
  }
}

/// Bouton cerclé de vert, plein quand l'action a été menée à bien.
class BoutonSecondaireCheckout extends StatelessWidget {
  const BoutonSecondaireCheckout({
    super.key,
    required this.label,
    required this.valide,
    required this.onTap,
  });

  final String label;
  final bool valide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return SizedBox(
      height: 44,
      child: Material(
        color: valide ? ClosetColors.emeraude100 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: rayon,
          side: const BorderSide(
            color: ClosetColors.vert,
            width: AppStroke.fin,
          ),
        ),
        child: InkWell(
          borderRadius: rayon,
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (valide) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: ClosetColors.vert,
                  ),
                  const SizedBox(width: AppSpacing.p8),
                ],
                Text(
                  label,
                  style: ClosetTextStyles.bouton.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feuille de sélection à une colonne — régions, départements, villes.
///
/// Toutes les listes de la maquette (`61:12575`, `61:12788`, `162:5536`)
/// partagent ce gabarit : titre, liste cochable, fond blanc arrondi en haut.
Future<T?> afficherSelecteur<T>({
  required BuildContext context,
  required String titre,
  required List<T> options,
  required String Function(T) libelle,
  T? selection,
  String Function(T)? sousTitre,
  bool recherchable = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _FeuilleSelecteur<T>(
        titre: titre,
        options: options,
        libelle: libelle,
        selection: selection,
        sousTitre: sousTitre,
        recherchable: recherchable,
      );
    },
  );
}

class _FeuilleSelecteur<T> extends StatefulWidget {
  const _FeuilleSelecteur({
    required this.titre,
    required this.options,
    required this.libelle,
    required this.recherchable,
    this.selection,
    this.sousTitre,
  });

  final String titre;
  final List<T> options;
  final String Function(T) libelle;
  final T? selection;
  final String Function(T)? sousTitre;
  final bool recherchable;

  @override
  State<_FeuilleSelecteur<T>> createState() => _FeuilleSelecteurState<T>();
}

class _FeuilleSelecteurState<T> extends State<_FeuilleSelecteur<T>> {
  String _filtre = '';

  @override
  Widget build(BuildContext context) {
    final needle = _filtre.trim().toLowerCase();
    final options = needle.isEmpty
        ? widget.options
        : [
            for (final o in widget.options)
              if (widget.libelle(o).toLowerCase().contains(needle)) o,
          ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.p12),
              const ClosetPoignee(couleur: ClosetColors.caseVide),
              const SizedBox(height: AppSpacing.p16),
              Text(widget.titre, style: ClosetTextStyles.titreBloc),
              if (widget.recherchable) ...[
                const SizedBox(height: AppSpacing.p12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                  ),
                  child: TextField(
                    autofocus: true,
                    onChanged: (v) => setState(() => _filtre = v),
                    style: ClosetTextStyles.saisie,
                    decoration: InputDecoration(
                      hintText: 'Rechercher…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.carte),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.p12),
              const ClosetFilet(couleur: ClosetColors.caseVide),
              Flexible(
                child: options.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.p24),
                        child: Text(
                          'Aucune ville ne correspond.',
                          style: ClosetTextStyles.meta,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.p8,
                        ),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, i) {
                          final option = options[i];
                          final choisi = option == widget.selection;
                          return ListTile(
                            title: Text(
                              widget.libelle(option),
                              style: ClosetTextStyles.libelle,
                            ),
                            subtitle: widget.sousTitre == null
                                ? null
                                : Text(
                                    widget.sousTitre!(option),
                                    style: ClosetTextStyles.meta.copyWith(
                                      color: ClosetColors.taupe,
                                    ),
                                  ),
                            trailing: Icon(
                              choisi
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: choisi
                                  ? ClosetColors.vert
                                  : ClosetColors.ligne,
                            ),
                            onTap: () => Navigator.of(context).pop(option),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
