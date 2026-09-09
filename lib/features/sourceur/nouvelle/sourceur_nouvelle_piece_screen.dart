import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// États alignés sur `PieceCondition` : `new` | `very_good` | `good`.
const List<(String api, String libelle)> etatsPiece = [
  ('new', 'Neuf'),
  ('very_good', 'Très bon état'),
  ('good', 'Bon état'),
];

/// Remise de la pièce — `collection_method` : `drop_off` | `pickup`.
const List<(String api, String libelle)> methodesCollecte = [
  ('drop_off', 'Dépôt en boutique'),
  ('pickup', 'Collecte à domicile'),
];

const typesArticle = [
  'Robe',
  'Chemise',
  'Pantalon',
  'Veste',
  'Manteau',
  'Jupe',
  'Pull',
  'T-shirt',
  'Blouse',
  'Ensemble',
  'Sac',
  'Chaussures',
  'Accessoire',
];

const taillesArticle = [
  'XS',
  'S',
  'M',
  'L',
  'XL',
  '34',
  '36',
  '38',
  '40',
  '42',
  '44',
];

/// Confier une pièce — transcription de la maquette `33:1389` (étape 2/4).
///
/// Trois sections coiffées de sur-titres dorés : spécificité de la pièce,
/// état, estimation, puis la zone de dépôt photo.
///
/// La pièce est réellement enregistrée via [SourceurRepository.deposerPiece],
/// puis l'écran d'inspection prend le relais — c'est le parcours dessiné dans
/// la section Figma `39:1262`.
class SourceurNouvellePieceScreen extends ConsumerStatefulWidget {
  const SourceurNouvellePieceScreen({super.key});

  @override
  ConsumerState<SourceurNouvellePieceScreen> createState() =>
      _SourceurNouvellePieceScreenState();
}

class _SourceurNouvellePieceScreenState
    extends ConsumerState<SourceurNouvellePieceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marque = TextEditingController();
  final _prix = TextEditingController();
  final _recit = TextEditingController();
  final _picker = ImagePicker();

  String _etat = etatsPiece.first.$1;
  String _methodeCollecte = methodesCollecte.first.$1;
  String? _type;
  String? _taille;
  bool _partageAutorise = false;
  final List<XFile> _medias = [];
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _marque.dispose();
    _prix.dispose();
    _recit.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) setState(() => _medias.add(image));
    } catch (_) {
      if (!mounted) return;
      toastErreur(ref, ClosetL10n.of(context).photosInaccessibles);
    }
  }

  Future<void> _importerMedias() async {
    try {
      final fichiers = await _picker.pickMultipleMedia(imageQuality: 85);
      if (fichiers.isNotEmpty && mounted) {
        setState(() => _medias.addAll(fichiers));
      }
    } catch (_) {
      if (!mounted) return;
      toastErreur(ref, ClosetL10n.of(context).galerieInaccessible);
    }
  }

  Future<void> _filmer() async {
    try {
      final video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null && mounted) setState(() => _medias.add(video));
    } catch (_) {
      if (!mounted) return;
      toastErreur(ref, ClosetL10n.of(context).cameraInaccessible);
    }
  }

  Future<void> _poursuivre() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _envoiEnCours = true);

    final piece = PieceDeposee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: (_type ?? '').trim(),
      univers: _marque.text.trim(),
      prix: _prixSaisi,
      imageUrl: _medias.isEmpty ? null : _medias.first.path,
      statut: StatutPiece.enRevue,
      taille: (_taille ?? '').trim().isEmpty ? null : _taille!.trim(),
      etat: _etat,
      recit: _recit.text.trim().isEmpty ? null : _recit.text.trim(),
      methodeCollecte: _methodeCollecte,
      partageAutorise: _partageAutorise,
    );
    final medias = [
      for (final f in _medias) FichierMedia(chemin: f.path, nom: f.name),
    ];

    try {
      final l10n = ClosetL10n.of(context);
      final id = await ClosetDialogue.executer(
        context,
        message: l10n.depotEnCours,
        action: () => ref
            .read<SourceurRepository>(sourceurRepositoryProvider)
            .deposerPiece(piece, medias: medias),
      );
      if (!mounted || id == null) return;
      setState(() => _envoiEnCours = false);
      ref.invalidate(mesPiecesProvider);

      unawaited(HapticFeedback.mediumImpact());
      await dialogueSucces(
        context,
        titre: l10n.pieceRecue,
        message: l10n.pieceEnExamen(piece.nom),
      );
      if (!mounted) return;
      context.go('/sourceur/piece/$id');
    } catch (e) {
      if (!mounted) return;
      await dialogueErreur(
        context,
        e,
        titre: ClosetL10n.of(context).depotImpossible,
      );
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  double get _prixSaisi {
    final brut = _prix.text.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(brut) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final maisons = [
      for (final m in ref.watch(maisonsProvider).value ?? const <Maison>[])
        m.nom,
    ];
    final types = {
      ...typesArticle,
      for (final u in ref.watch(universProvider).value ?? const <Univers>[])
        u.nom,
    }.toList()
      ..sort();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ListeDeroulante(
                        label: 'Type d’article',
                        valeur: _type,
                        options: types,
                        hint: 'Veste',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Précisez le type d’article.'
                                : null,
                        onChanged: (v) => setState(() => _type = v),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ChampMarque(
                              controller: _marque,
                              suggestions: maisons,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.p20),
                          Expanded(
                            child: _ListeDeroulante(
                              label: 'Taille',
                              valeur: _taille,
                              options: taillesArticle,
                              hint: 'M',
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Indiquez la taille.'
                                      : null,
                              onChanged: (v) => setState(() => _taille = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      Wrap(
                        spacing: AppSpacing.p12,
                        runSpacing: AppSpacing.p16,
                        children: [
                          for (final etat in etatsPiece)
                            ClosetChip(
                              label: etat.$2,
                              isActive: etat.$1 == _etat,
                              onTap: () => setState(() => _etat = etat.$1),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      _Champ(
                        label: 'Prix souhaité',
                        hint: '30.000',
                        controller: _prix,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _validerPrix,
                        inputFormatters: const [_SeparateurMilliers()],
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      Text(
                        'ClosET valorise chaque pièce selon ses critères de '
                        'qualité et d’élégance.',
                        style: ClosetTextStyles.labelChamp.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ClosetColors.neutre700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      _Champ(
                        label: 'Récit (facultatif)',
                        hint: 'D’où vient cette pièce, et pourquoi la confier.',
                        controller: _recit,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: 4,
                        minLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      Wrap(
                        spacing: AppSpacing.p12,
                        runSpacing: AppSpacing.p16,
                        children: [
                          for (final methode in methodesCollecte)
                            ClosetChip(
                              label: methode.$2,
                              isActive: methode.$1 == _methodeCollecte,
                              onTap: () =>
                                  setState(() => _methodeCollecte = methode.$1),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _partageAutorise,
                        onChanged: (v) => setState(() => _partageAutorise = v),
                        title: Text(
                          'Autoriser ClosET à partager cette pièce',
                          style: ClosetTextStyles.labelChamp.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ClosetColors.vert,
                          ),
                        ),
                        subtitle: Text(
                          'ClosET pourra relayer le visuel et le récit.',
                          style: ClosetTextStyles.corps.copyWith(
                            color: ClosetColors.neutre700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      _ZoneDepotPhotos(
                        medias: _medias,
                        onPrendre: () => _choisirPhoto(ImageSource.camera),
                        onFilmer: _filmer,
                        onImporter: _importerMedias,
                        onRetirer: (i) => setState(() => _medias.removeAt(i)),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      Center(
                        child: SizedBox(
                          width: 312,
                          height: 44,
                          child: Material(
                            color: _envoiEnCours
                                ? ClosetColors.sauge
                                : ClosetColors.vert,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cercle),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cercle),
                              onTap: _envoiEnCours ? null : _poursuivre,
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
                                        'Poursuivre',
                                        style: ClosetTextStyles.libelleFort
                                            .copyWith(color: ClosetColors.blanc),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _validerPrix(String? v) {
    final brut = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (brut.isEmpty) return 'Indiquez un prix souhaité.';
    final montant = int.tryParse(brut);
    if (montant == null || montant <= 0) return 'Ce prix semble incorrect.';
    return null;
  }
}

class _SeparateurMilliers extends TextInputFormatter {
  const _SeparateurMilliers();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue ancien,
    TextEditingValue suivant,
  ) {
    final chiffres = suivant.text.replaceAll(RegExp(r'[^\d]'), '');
    if (chiffres.isEmpty) {
      return suivant.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < chiffres.length; i++) {
      if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write('.');
      buffer.write(chiffres[i]);
    }
    final texte = buffer.toString();
    return TextEditingValue(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
  }
}

class _ListeDeroulante extends StatelessWidget {
  const _ListeDeroulante({
    required this.label,
    required this.valeur,
    required this.options,
    required this.hint,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String? valeur;
  final List<String> options;
  final String hint;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final choix = {
      if (valeur != null && valeur!.isNotEmpty) valeur!,
      ...options,
    }.toList();

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
        DropdownButtonFormField<String>(
          initialValue: choix.contains(valeur) ? valeur : null,
          hint: Text(
            hint,
            style: ClosetTextStyles.saisie.copyWith(
              color: ClosetColors.placeholderGris,
            ),
          ),
          items: [
            for (final o in choix)
              DropdownMenuItem(
                value: o,
                child: Text(o, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
          validator: validator,
          style: ClosetTextStyles.saisie.copyWith(color: ClosetColors.noir),
          icon: const Icon(Icons.expand_more, color: ClosetColors.vert),
          decoration: InputDecoration(
            filled: true,
            fillColor: ClosetColors.blanc,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p16,
              vertical: AppSpacing.p12,
            ),
            border: _Champ._bordure(ClosetColors.fond300),
            enabledBorder: _Champ._bordure(ClosetColors.fond300),
            focusedBorder: _Champ._bordure(ClosetColors.vert),
            errorBorder: _Champ._bordure(ClosetColors.erreurCouture),
            focusedErrorBorder: _Champ._bordure(ClosetColors.erreurCouture),
          ),
        ),
      ],
    );
  }
}

class _ChampMarque extends StatelessWidget {
  const _ChampMarque({
    required this.controller,
    required this.suggestions,
  });

  final TextEditingController controller;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marque (si connue)',
          style: ClosetTextStyles.labelChamp.copyWith(
            fontWeight: FontWeight.w500,
            color: ClosetColors.vert,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: controller.text),
          optionsBuilder: (texte) {
            final q = texte.text.trim().toLowerCase();
            if (q.isEmpty) return suggestions.take(8);
            return suggestions.where((s) => s.toLowerCase().contains(q));
          },
          onSelected: (v) => controller.text = v,
          fieldViewBuilder: (
            context,
            champController,
            focus,
            onSubmitted,
          ) {
            return TextFormField(
              controller: champController,
              focusNode: focus,
              textInputAction: TextInputAction.next,
              maxLength: 120,
              textCapitalization: TextCapitalization.words,
              onChanged: (v) => controller.text = v,
              style: ClosetTextStyles.saisie.copyWith(color: ClosetColors.noir),
              cursorColor: ClosetColors.vert,
              decoration: InputDecoration(
                hintText: 'Lin & Co',
                hintStyle: ClosetTextStyles.saisie.copyWith(
                  color: ClosetColors.placeholderGris,
                ),
                counterText: '',
                filled: true,
                fillColor: ClosetColors.blanc,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                  vertical: AppSpacing.p12,
                ),
                border: _Champ._bordure(ClosetColors.fond300),
                enabledBorder: _Champ._bordure(ClosetColors.fond300),
                focusedBorder: _Champ._bordure(ClosetColors.vert),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Champ du formulaire : libellé vert, zone blanche de 42 cerclée d'or.
class _Champ extends StatelessWidget {
  const _Champ({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;

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
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.sentences,
          style: ClosetTextStyles.saisie.copyWith(color: ClosetColors.noir),
          cursorColor: ClosetColors.vert,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ClosetTextStyles.saisie.copyWith(
              color: ClosetColors.placeholderGris,
            ),
            counterText: '',
            filled: true,
            fillColor: ClosetColors.blanc,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p16,
              vertical: AppSpacing.p12,
            ),
            border: _bordure(ClosetColors.fond300),
            enabledBorder: _bordure(ClosetColors.fond300),
            focusedBorder: _bordure(ClosetColors.vert),
            errorBorder: _bordure(ClosetColors.erreurCouture),
            focusedErrorBorder: _bordure(ClosetColors.erreurCouture),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _bordure(Color couleur) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        borderSide: BorderSide(color: couleur, width: AppStroke.fin),
      );
}

bool _estVideo(XFile fichier) {
  final mime = fichier.mimeType?.toLowerCase() ?? '';
  if (mime.startsWith('video')) return true;
  final nom = fichier.name.toLowerCase();
  return nom.endsWith('.mp4') ||
      nom.endsWith('.mov') ||
      nom.endsWith('.webm') ||
      nom.endsWith('.m4v');
}

/// Zone de dépôt : plusieurs photos ou vidéos avant l'envoi.
class _ZoneDepotPhotos extends StatelessWidget {
  const _ZoneDepotPhotos({
    required this.medias,
    required this.onPrendre,
    required this.onFilmer,
    required this.onImporter,
    required this.onRetirer,
  });

  final List<XFile> medias;
  final VoidCallback onPrendre;
  final VoidCallback onFilmer;
  final VoidCallback onImporter;
  final ValueChanged<int> onRetirer;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ClosetColors.bordurePointillee,
          width: AppStroke.fin,
        ),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacing.p12,
            runSpacing: AppSpacing.p12,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < medias.length; i++)
                _VignetteMedia(
                  fichier: medias[i],
                  onRetirer: () => onRetirer(i),
                ),
              if (medias.isEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 80,
                    height: 80,
                    child: ColoredBox(
                      color: ClosetColors.vert,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: 30,
                        color: ClosetColors.blanc,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(
            medias.isEmpty
                ? 'Ajoutez photos et vidéos avant de soumettre. Facultatif.'
                : '${medias.length} média${medias.length > 1 ? 's' : ''} ajouté${medias.length > 1 ? 's' : ''}. Vous pouvez en joindre d’autres.',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.corps.copyWith(
              letterSpacing: 0,
              color: ClosetColors.neutre700,
            ),
          ),
          const SizedBox(height: AppSpacing.p20),
          Row(
            children: [
              Expanded(
                child: _BoutonPhoto(
                  label: 'Photo',
                  plein: false,
                  onTap: onPrendre,
                ),
              ),
              const SizedBox(width: AppSpacing.p8),
              Expanded(
                child: _BoutonPhoto(
                  label: 'Vidéo',
                  plein: false,
                  onTap: onFilmer,
                ),
              ),
              const SizedBox(width: AppSpacing.p8),
              Expanded(
                child: _BoutonPhoto(
                  label: 'Importer',
                  plein: true,
                  onTap: onImporter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VignetteMedia extends StatelessWidget {
  const _VignetteMedia({required this.fichier, required this.onRetirer});

  final XFile fichier;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 80,
            height: 80,
            child: _estVideo(fichier)
                ? const ColoredBox(
                    color: ClosetColors.vert,
                    child: Icon(
                      Icons.videocam_outlined,
                      size: 30,
                      color: ClosetColors.blanc,
                    ),
                  )
                : Image.file(File(fichier.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Semantics(
            button: true,
            label: 'Retirer le média',
            child: GestureDetector(
              onTap: onRetirer,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: ClosetColors.erreurCouture,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 13,
                  color: ClosetColors.blanc,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BoutonPhoto extends StatelessWidget {
  const _BoutonPhoto({
    required this.label,
    required this.plein,
    required this.onTap,
  });

  final String label;
  final bool plein;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return SizedBox(
      height: 44,
      child: Material(
        color: plein ? ClosetColors.vert : ClosetColors.blanc,
        shape: RoundedRectangleBorder(
          borderRadius: rayon,
          side: plein
              ? BorderSide.none
              : const BorderSide(
                  color: ClosetColors.bordureBoutonClair,
                  width: AppStroke.fin,
                ),
        ),
        child: InkWell(
          borderRadius: rayon,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ClosetTextStyles.libelle.copyWith(
                color: plein ? ClosetColors.blanc : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
