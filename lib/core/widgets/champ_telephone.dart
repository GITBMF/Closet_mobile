import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import '../validation/indicateurs_pays.dart';

/// Habillage du champ téléphone selon l’écran hôte.
enum StyleChampTelephone { auth, libelle, checkout, sourceur }

/// Pays + numéro national, exposés en E.164 (`+237699000000`).
class TelephoneController extends ChangeNotifier {
  TelephoneController({String? initial}) {
    national.addListener(_surNational);
    if (initial != null && initial.trim().isNotEmpty) {
      appliquer(initial);
    }
  }

  IndicateurPays pays = IndicateurPays.cameroun;
  final TextEditingController national = TextEditingController();
  bool _ecritureInterne = false;

  String get e164 {
    final n = national.text.replaceAll(RegExp(r'\D'), '');
    if (n.isEmpty) return '';
    return '+${pays.indicatif}$n';
  }

  bool get estValide =>
      validerTelephone(e164, obligatoire: true) == null;

  void choisirPays(IndicateurPays suivant) {
    if (pays.iso == suivant.iso && pays.nom == suivant.nom) return;
    pays = suivant;
    notifyListeners();
  }

  void appliquer(String brut) {
    final parse = IndicateurPays.analyser(brut);
    if (parse != null) {
      pays = parse.pays;
      _ecrireNational(parse.national);
    } else {
      _ecrireNational(brut.replaceAll(RegExp(r'\D'), ''));
    }
    notifyListeners();
  }

  void _surNational() {
    if (_ecritureInterne) return;
    final brut = national.text;
    if (brut.contains('+') ||
        brut.startsWith('00') ||
        IndicateurPays.analyser(brut) != null) {
      final parse = IndicateurPays.analyser(brut);
      if (parse != null) {
        pays = parse.pays;
        if (parse.national != national.text.replaceAll(RegExp(r'\D'), '')) {
          _ecrireNational(parse.national);
        }
      }
    }
    notifyListeners();
  }

  void _ecrireNational(String texte) {
    _ecritureInterne = true;
    national.value = TextEditingValue(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
    _ecritureInterne = false;
  }

  @override
  void dispose() {
    national.removeListener(_surNational);
    national.dispose();
    super.dispose();
  }
}

/// Téléphone : indicateur (drapeau + code) + numéro national + recherche.
class ChampTelephone extends StatefulWidget {
  const ChampTelephone({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.style = StyleChampTelephone.libelle,
    this.obligatoire = true,
    this.validerAvecLeFormulaire = true,
    this.validator,
    this.onChanged,
    this.icone,
    this.textInputAction,
  });

  final String label;
  final TelephoneController? controller;
  final String? hint;
  final StyleChampTelephone style;
  final bool obligatoire;
  final bool validerAvecLeFormulaire;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final IconData? icone;
  final TextInputAction? textInputAction;

  @override
  State<ChampTelephone> createState() => _ChampTelephoneState();
}

class _ChampTelephoneState extends State<ChampTelephone> {
  late TelephoneController _ctrl;
  late bool _possede;

  @override
  void initState() {
    super.initState();
    _possede = widget.controller == null;
    _ctrl = widget.controller ?? TelephoneController();
    _ctrl.addListener(_relayer);
  }

  @override
  void didUpdateWidget(covariant ChampTelephone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _ctrl.removeListener(_relayer);
      if (_possede) _ctrl.dispose();
      _possede = widget.controller == null;
      _ctrl = widget.controller ?? TelephoneController();
      _ctrl.addListener(_relayer);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_relayer);
    if (_possede) _ctrl.dispose();
    super.dispose();
  }

  void _relayer() {
    if (mounted) setState(() {});
  }

  Future<void> _ouvrirPays() async {
    final choix = await afficherSelecteurPays(
      context,
      selection: _ctrl.pays,
    );
    if (choix != null) {
      _ctrl.choisirPays(choix);
      widget.onChanged?.call(_ctrl.e164);
    }
  }

  String? _valider(String? _) =>
      widget.validator?.call(_ctrl.e164) ??
      validerTelephone(
        _ctrl.e164,
        obligatoire: widget.obligatoire,
        libelle: 'numéro',
      );

  @override
  Widget build(BuildContext context) {
    if (widget.validerAvecLeFormulaire) {
      return FormField<String>(
        validator: _valider,
        builder: (etat) {
          return _HabillageTelephone(
            label: widget.label,
            hint: widget.hint ?? '6 90 12 34 56',
            style: widget.style,
            icone: widget.icone,
            ctrl: _ctrl,
            textInputAction: widget.textInputAction,
            erreur: etat.errorText,
            onPays: _ouvrirPays,
            onChanged: () {
              etat.didChange(_ctrl.e164);
              widget.onChanged?.call(_ctrl.e164);
            },
          );
        },
      );
    }
    return _HabillageTelephone(
      label: widget.label,
      hint: widget.hint ?? '6 90 12 34 56',
      style: widget.style,
      icone: widget.icone,
      ctrl: _ctrl,
      textInputAction: widget.textInputAction,
      onPays: _ouvrirPays,
      onChanged: () => widget.onChanged?.call(_ctrl.e164),
    );
  }
}

class _HabillageTelephone extends StatelessWidget {
  const _HabillageTelephone({
    required this.label,
    required this.hint,
    required this.style,
    required this.ctrl,
    required this.onPays,
    required this.onChanged,
    this.icone,
    this.textInputAction,
    this.erreur,
  });

  final String label;
  final String hint;
  final StyleChampTelephone style;
  final IconData? icone;
  final TelephoneController ctrl;
  final TextInputAction? textInputAction;
  final String? erreur;
  final VoidCallback onPays;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final champ = switch (style) {
      StyleChampTelephone.sourceur => _ChampSourceurTel(
          hint: hint,
          ctrl: ctrl,
          textInputAction: textInputAction,
          onPays: onPays,
          onChanged: onChanged,
        ),
      StyleChampTelephone.auth => _ChampEncadreTel(
          hint: hint,
          ctrl: ctrl,
          textInputAction: textInputAction,
          onPays: onPays,
          onChanged: onChanged,
          fond: ClosetColors.champFond,
          bordure: ClosetColors.champBordure,
          focus: ClosetColors.fond300,
          hauteur: 42,
        ),
      StyleChampTelephone.libelle => _ChampEncadreTel(
          hint: hint,
          ctrl: ctrl,
          textInputAction: textInputAction,
          onPays: onPays,
          onChanged: onChanged,
          fond: context.closetChamp,
          bordure: ClosetColors.fond300,
          focus: ClosetColors.vert,
          hauteur: 42,
        ),
      StyleChampTelephone.checkout => _ChampEncadreTel(
          hint: hint,
          ctrl: ctrl,
          textInputAction: textInputAction,
          onPays: onPays,
          onChanged: onChanged,
          fond: context.closetChamp,
          bordure: ClosetColors.fond300,
          focus: ClosetColors.vert,
          hauteur: null,
        ),
    };

    final libelle = switch (style) {
      StyleChampTelephone.auth => Text(
          label,
          style: ClosetTextStyles.labelChamp.copyWith(
            color: ClosetColors.fond300,
          ),
        ),
      StyleChampTelephone.sourceur => Row(
          children: [
            if (icone != null) ...[
              Icon(icone, size: 16, color: ClosetColors.dore),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: ClosetTextStyles.labelChamp,
              ),
            ),
          ],
        ),
      StyleChampTelephone.libelle || StyleChampTelephone.checkout => Text(
          label,
          style: ClosetTextStyles.labelChamp.copyWith(
            fontWeight: FontWeight.w500,
            color: ClosetColors.vert,
          ),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        libelle,
        const SizedBox(height: AppSpacing.p8),
        champ,
        if (erreur != null) ...[
          const SizedBox(height: 6),
          Text(
            erreur!,
            style: ClosetTextStyles.meta.copyWith(
              color: ClosetColors.erreur,
            ),
          ),
        ],
      ],
    );
  }
}

class _ChampEncadreTel extends StatelessWidget {
  const _ChampEncadreTel({
    required this.hint,
    required this.ctrl,
    required this.onPays,
    required this.onChanged,
    required this.fond,
    required this.bordure,
    required this.focus,
    required this.hauteur,
    this.textInputAction,
  });

  final String hint;
  final TelephoneController ctrl;
  final VoidCallback onPays;
  final VoidCallback onChanged;
  final Color fond;
  final Color bordure;
  final Color focus;
  final double? hauteur;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final champ = TextField(
      controller: ctrl.national,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\s]')),
      ],
      onChanged: (_) => onChanged(),
      style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
      cursorColor: ClosetColors.vert,
      cursorWidth: 1.5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ClosetTextStyles.saisie.copyWith(
          color: ClosetColors.champPlaceholder,
        ),
        filled: true,
        fillColor: fond,
        isDense: true,
        prefixIcon: _BoutonIndicateur(
          pays: ctrl.pays,
          onTap: onPays,
          sombre: false,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 88, minHeight: 40),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p12,
          vertical: AppSpacing.p12,
        ),
        border: _bordure(bordure),
        enabledBorder: _bordure(bordure),
        focusedBorder: _bordure(focus),
        errorBorder: _bordure(ClosetColors.erreur),
        focusedErrorBorder: _bordure(ClosetColors.erreur),
      ),
    );
    if (hauteur == null) return champ;
    return SizedBox(height: hauteur, child: champ);
  }

  static OutlineInputBorder _bordure(Color couleur) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        borderSide: BorderSide(color: couleur, width: AppStroke.fin),
      );
}

class _ChampSourceurTel extends StatelessWidget {
  const _ChampSourceurTel({
    required this.hint,
    required this.ctrl,
    required this.onPays,
    required this.onChanged,
    this.textInputAction,
  });

  final String hint;
  final TelephoneController ctrl;
  final VoidCallback onPays;
  final VoidCallback onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: ctrl.national,
        keyboardType: TextInputType.phone,
        textInputAction: textInputAction,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d+\s]')),
        ],
        onChanged: (_) => onChanged(),
        style: ClosetTextStyles.saisie.copyWith(color: cs.onSurface),
        cursorColor: cs.primary,
        cursorWidth: 1.5,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ClosetTextStyles.saisieHint.copyWith(
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
          border: InputBorder.none,
          isDense: true,
          prefixIcon: _BoutonIndicateur(
            pays: ctrl.pays,
            onTap: onPays,
            sombre: true,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 88, minHeight: 40),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _BoutonIndicateur extends StatelessWidget {
  const _BoutonIndicateur({
    required this.pays,
    required this.onTap,
    required this.sombre,
  });

  final IndicateurPays pays;
  final VoidCallback onTap;
  final bool sombre;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Indicatif ${pays.nom} ${pays.libelleCourt}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pays.drapeau, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                pays.libelleCourt,
                style: ClosetTextStyles.saisie.copyWith(
                  fontWeight: FontWeight.w600,
                  color: sombre ? context.closetEncre : ClosetColors.vert,
                ),
              ),
              Icon(
                Icons.expand_more,
                size: 16,
                color: sombre ? ClosetColors.taupe : ClosetColors.champPlaceholder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<IndicateurPays?> afficherSelecteurPays(
  BuildContext context, {
  required IndicateurPays selection,
}) {
  return showModalBottomSheet<IndicateurPays>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ClosetColors.blanc,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SelecteurPaysSheet(selection: selection),
  );
}

class _SelecteurPaysSheet extends StatefulWidget {
  const _SelecteurPaysSheet({required this.selection});

  final IndicateurPays selection;

  @override
  State<_SelecteurPaysSheet> createState() => _SelecteurPaysSheetState();
}

class _SelecteurPaysSheetState extends State<_SelecteurPaysSheet> {
  final _recherche = TextEditingController();

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liste = IndicateurPays.rechercher(_recherche.text);
    final hauteur = MediaQuery.sizeOf(context).height * 0.72;
    return SizedBox(
      height: hauteur,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ClosetColors.fond200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Indicatif du pays',
              style: ClosetTextStyles.titreBloc.copyWith(
                color: ClosetColors.vert,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _recherche,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              style: ClosetTextStyles.saisie,
              decoration: InputDecoration(
                hintText: 'Pays ou indicatif…',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: ClosetColors.champFond,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.carte),
                  borderSide: const BorderSide(color: ClosetColors.champBordure),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.carte),
                  borderSide: const BorderSide(color: ClosetColors.champBordure),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: liste.length,
              itemBuilder: (context, i) {
                final p = liste[i];
                final choisi = p.iso == widget.selection.iso &&
                    p.nom == widget.selection.nom;
                return ListTile(
                  leading: Text(p.drapeau, style: const TextStyle(fontSize: 22)),
                  title: Text(p.nom, style: ClosetTextStyles.corps),
                  trailing: Text(
                    p.libelleCourt,
                    style: ClosetTextStyles.saisie.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.vert,
                    ),
                  ),
                  selected: choisi,
                  onTap: () => Navigator.of(context).pop(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
