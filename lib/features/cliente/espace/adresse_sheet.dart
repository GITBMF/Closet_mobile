import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/adresse.dart';
import '../../../data/repositories/adresse_repository.dart';
import '../../checkout/widgets/checkout_widgets.dart';

/// Ajout ou modification d'une adresse — complément de `26:1588`.
///
/// La maquette montre la liste et son bouton « + » mais ne dessine pas le
/// formulaire. Il reprend donc le gabarit de champ du checkout, seul formulaire
/// d'adresse que la maquette détaille, plutôt que d'inventer un style.
///
/// Renvoie `true` si quelque chose a été enregistré ou supprimé.
Future<bool> afficherFormulaireAdresse(
  BuildContext context, {
  Adresse? adresse,
}) async {
  final resultat = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AdresseSheet(adresse: adresse),
  );
  return resultat ?? false;
}

class _AdresseSheet extends ConsumerStatefulWidget {
  const _AdresseSheet({this.adresse});

  /// Adresse à modifier. Nulle pour une création.
  final Adresse? adresse;

  @override
  ConsumerState<_AdresseSheet> createState() => _AdresseSheetState();
}

class _AdresseSheetState extends ConsumerState<_AdresseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _libelle;
  late final TextEditingController _ligne;
  late TypeAdresse _type;
  late bool _parDefaut;
  bool _envoiEnCours = false;

  bool get _modification => widget.adresse != null;

  @override
  void initState() {
    super.initState();
    final a = widget.adresse;
    _libelle = TextEditingController(text: a?.libelle ?? '');
    _ligne = TextEditingController(text: a?.ligne ?? '');
    _type = a?.type ?? TypeAdresse.maison;
    _parDefaut = a?.parDefaut ?? false;
  }

  @override
  void dispose() {
    _libelle.dispose();
    _ligne.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_envoiEnCours) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _envoiEnCours = true);
    final depot = ref.read(adresseRepositoryProvider);
    try {
      await depot.enregistrer(
        Adresse(
          id: widget.adresse?.id ?? await depot.prochainId(),
          libelle: _libelle.text.trim(),
          ligne: _ligne.text.trim(),
          type: _type,
          parDefaut: _parDefaut,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  Future<void> _supprimer() async {
    final adresse = widget.adresse;
    if (adresse == null) return;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ClosetColors.blanc,
        title: Text('Supprimer cette adresse ?',
            style: ClosetTextStyles.titreBloc),
        content: Text(
          'Elle ne sera plus proposée au moment de commander.',
          style: ClosetTextStyles.corps,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler',
                style:
                    ClosetTextStyles.bouton.copyWith(color: ClosetColors.taupe)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Supprimer',
              style: ClosetTextStyles.bouton.copyWith(
                color: ClosetColors.erreurCouture,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    await ref.read(adresseRepositoryProvider).supprimer(adresse.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ClosetColors.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.p24,
            AppSpacing.p20,
            AppSpacing.p24,
            AppSpacing.p20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ClosetColors.fond300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.p20),
                Text(
                  _modification ? 'Modifier l’adresse' : 'Nouvelle adresse',
                  style: ClosetTextStyles.titreBloc,
                ),
                const SizedBox(height: AppSpacing.p24),
                ChampCheckout(
                  label: 'Libellé',
                  hint: 'Maison',
                  controller: _libelle,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Donnez un nom à cette adresse.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.p20),
                ChampCheckout(
                  label: 'Adresse',
                  hint: 'Yaoundé, Bastos — Rond-point, immeuble Kaba',
                  controller: _ligne,
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Précisez la ville et le quartier.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.p20),
                Text(
                  'Type',
                  style: ClosetTextStyles.labelChamp.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ClosetColors.vert,
                  ),
                ),
                const SizedBox(height: AppSpacing.p8),
                Wrap(
                  spacing: AppSpacing.p8,
                  children: [
                    for (final t in TypeAdresse.values)
                      ChoiceChip(
                        label: Text(_libelleType(t)),
                        selected: t == _type,
                        onSelected: (_) => setState(() => _type = t),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _parDefaut,
                  activeThumbColor: ClosetColors.vert,
                  title: Text(
                    'Adresse par défaut',
                    style: ClosetTextStyles.libelle,
                  ),
                  subtitle: Text(
                    'Proposée en premier au moment de commander.',
                    style: ClosetTextStyles.meta.copyWith(
                      color: ClosetColors.taupe,
                    ),
                  ),
                  onChanged: (v) => setState(() => _parDefaut = v),
                ),
                const SizedBox(height: AppSpacing.p12),
                SizedBox(
                  height: 44,
                  child: Material(
                    color: ClosetColors.vert,
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.cercle),
                      onTap: _envoiEnCours ? null : _enregistrer,
                      child: Center(
                        child: _envoiEnCours
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ClosetColors.blanc,
                                ),
                              )
                            : Text(
                                'Enregistrer',
                                style: ClosetTextStyles.bouton.copyWith(
                                  color: ClosetColors.blanc,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                if (_modification) ...[
                  const SizedBox(height: AppSpacing.p12),
                  TextButton(
                    onPressed: _envoiEnCours ? null : _supprimer,
                    child: Text(
                      'Supprimer cette adresse',
                      style: ClosetTextStyles.bouton.copyWith(
                        color: ClosetColors.erreurCouture,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _libelleType(TypeAdresse t) => switch (t) {
        TypeAdresse.maison => 'Maison',
        TypeAdresse.bureau => 'Bureau',
        TypeAdresse.appartement => 'Appartement',
        TypeAdresse.autre => 'Autre',
      };
}
