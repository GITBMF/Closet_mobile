import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Champ de saisie — transcription du composant Figma `61:12575`.
///
/// Fond blanc, bordure dorée fine (rayon 8), et **libellé posé sur la bordure
/// supérieure** en encoche (Lato 500 / 12 pt, vert profond). Le contenu est en
/// Lato 500 / 14 pt.
///
/// Diffère de `LabeledField` (espace sourceur), qui place son libellé au-dessus
/// du champ en capitales dorées.
class ClosetField extends StatelessWidget {
  const ClosetField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      style: ClosetTextStyles.saisie.copyWith(fontWeight: FontWeight.w500),
      cursorColor: ClosetColors.vert,
      cursorWidth: 1.5,
      decoration: closetFieldDecoration(
        label: label,
        hint: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Décoration partagée par [ClosetField] et [ClosetSelectField], pour que les
/// deux restent alignés sur la même spec Figma.
InputDecoration closetFieldDecoration({
  required String label,
  String? hint,
  Widget? suffixIcon,
}) {
  OutlineInputBorder bordure(Color couleur, double epaisseur) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.carte),
      borderSide: BorderSide(color: couleur, width: epaisseur),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: ClosetTextStyles.labelChamp.copyWith(
      color: ClosetColors.vert,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: ClosetTextStyles.saisieHint,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.p16,
      vertical: AppSpacing.p16,
    ),
    border: bordure(ClosetColors.fond300, AppStroke.fin),
    enabledBorder: bordure(ClosetColors.fond300, AppStroke.fin),
    focusedBorder: bordure(ClosetColors.vert, AppStroke.moyen),
    errorBorder: bordure(ClosetColors.erreur, AppStroke.fin),
    focusedErrorBorder: bordure(ClosetColors.erreur, AppStroke.moyen),
    disabledBorder: bordure(ClosetColors.ligne, AppStroke.fin),
  );
}

/// Champ déroulant — même habillage que [ClosetField], avec la liste
/// d'options séparée par des filets gris (`#E3E3E3` dans la maquette).
class ClosetSelectField<T> extends StatelessWidget {
  const ClosetSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
  });

  final String label;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      style: ClosetTextStyles.saisie.copyWith(fontWeight: FontWeight.w500),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: ClosetColors.taupe),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.carte),
      decoration: closetFieldDecoration(label: label, hint: hint),
      items: [
        for (var i = 0; i < items.length; i++)
          DropdownMenuItem<T>(
            value: items[i],
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
              decoration: i == items.length - 1
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ClosetColors.separateur,
                          width: AppStroke.fin,
                        ),
                      ),
                    ),
              child: Text(
                itemLabel(items[i]),
                style: ClosetTextStyles.saisie.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
