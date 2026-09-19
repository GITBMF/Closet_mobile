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
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// États alignés sur `PieceCondition` : `new` | `very_good` | `good`.
List<(String api, String libelle)> etatsPiecePour(ClosetL10n l10n) => [
      ('new', l10n.etatNeuf),
      ('very_good', l10n.etatTresBonEtat),
      ('good', l10n.etatBonEtat),
    ];

List<String> typesArticlePour(ClosetL10n l10n) => [
      l10n.typeRobe,
      l10n.typeChemise,
      l10n.typePantalon,
      l10n.typeVeste,
      l10n.typeManteau,
      l10n.typeJupe,
      l10n.typePull,
      l10n.typeTshirt,
      l10n.typeBlouse,
      l10n.typeEnsemble,
      l10n.typeSac,
      l10n.typeChaussures,
      l10n.typeAccessoire,
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

/// Confier une pièce — dépôt en 3 étapes : photos, type, marque + taille.
///
/// `condition_claimed` et `desired_price` restent exigés par
/// `POST /sourcing/submissions` : ils tiennent sur la dernière étape, en
/// bandeau compact. Récit, collecte et partage sont omis (défauts API).
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
  final _picker = ImagePicker();

  String _etat = 'very_good';
  String? _type;
  String? _taille;
  int _etape = 0;
  final List<XFile> _medias = [];
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _marque.dispose();
    _prix.dispose();
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
      recit: null,
      methodeCollecte: 'drop_off',
      partageAutorise: false,
    );
    final medias = [
      for (final f in _medias) FichierMedia(chemin: f.path, nom: f.name),
    ];

    try {
      final l10n = ClosetL10n.of(context);
      final resultat = await ClosetDialogue.executer(
        context,
        message: l10n.depotEnCours,
        action: () => ref
            .read<SourceurRepository>(sourceurRepositoryProvider)
            .deposerPiece(piece, medias: medias, l10n: l10n),
      );
      if (!mounted || resultat == null) return;
      setState(() => _envoiEnCours = false);
      ref.invalidate(mesPiecesProvider);

      unawaited(HapticFeedback.mediumImpact());
      await dialogueSucces(
        context,
        titre: l10n.pieceRecue,
        message: resultat.aDesMediasEnEchec
            ? '${l10n.pieceEnExamen(piece.nom)}\n\n${l10n.photosNonJointesMessage}'
            : l10n.pieceEnExamen(piece.nom),
      );
      if (!mounted) return;
      context.go('/sourceur/piece/${resultat.id}');
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

  List<String> get _titresEtape {
    final l10n = ClosetL10n.of(context);
    return [
      l10n.depotEtapePhotos,
      l10n.depotEtapeType,
      l10n.depotEtapeDetails,
    ];
  }

  void _revenir() {
    if (_etape == 0) return;
    setState(() => _etape -= 1);
  }

  Future<void> _avancer() async {
    final l10n = ClosetL10n.of(context);
    if (_etape == 0 && _medias.isEmpty) {
      toastInfo(ref, l10n.depotEtapePhotos, l10n.depotPhotoRequise);
      return;
    }
    if (_etape == 1 && (_type == null || _type!.trim().isEmpty)) {
      toastInfo(ref, l10n.depotEtapeType, l10n.depotTypeRequis);
      return;
    }
    if (_etape == 2) {
      if (_taille == null || _taille!.trim().isEmpty) {
        toastInfo(ref, l10n.depotEtapeDetails, 'Indiquez la taille.');
        return;
      }
      await _poursuivre();
      return;
    }
    setState(() => _etape += 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final maisons = [
      for (final m in ref.watch(maisonsProvider).value ?? const <Maison>[])
        m.nom,
    ];
    final types = {
      ...typesArticlePour(l10n),
      for (final u in ref.watch(universProvider).value ?? const <Univers>[])
        u.nom,
    }.toList()
      ..sort();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: _titresEtape[_etape],
              surtitre: l10n.etapeDepot(_etape + 1),
              afficherRetour: _etape > 0,
              onRetour: _revenir,
            ),
            _BarreEtapes(etape: _etape),
            Expanded(
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: SingleChildScrollView(
                    key: ValueKey(_etape),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.p20,
                      AppSpacing.p20,
                      AppSpacing.p20,
                      AppSpacing.p24,
                    ),
                    child: switch (_etape) {
                      0 => _EtapePhotos(
                          medias: _medias,
                          aide: l10n.depotPhotosAide,
                          onPrendre: () => _choisirPhoto(ImageSource.camera),
                          onFilmer: _filmer,
                          onImporter: _importerMedias,
                          onRetirer: (i) => setState(() => _medias.removeAt(i)),
                        ),
                      1 => _EtapeType(
                          types: types,
                          choisi: _type,
                          onChoix: (v) => setState(() => _type = v),
                        ),
                      _ => _EtapeDetails(
                          marque: _marque,
                          maisons: maisons,
                          taille: _taille,
                          etat: _etat,
                          prix: _prix,
                          onTaille: (v) => setState(() => _taille = v),
                          onEtat: (v) => setState(() => _etat = v),
                        ),
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.p20,
                0,
                AppSpacing.p20,
                AppSpacing.p16,
              ),
              child: SizedBox(
                height: 44,
                width: double.infinity,
                child: Material(
                  color: _envoiEnCours ? ClosetColors.sauge : ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: _envoiEnCours ? null : _avancer,
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
                              _etape == 2
                                  ? l10n.depotConfierCta
                                  : l10n.depotContinuer,
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
    );
  }

  static String? _validerPrix(String? v, ClosetL10n l10n) {
    final brut = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (brut.isEmpty) return l10n.nouvellePieceIndiquerPrix;
    final montant = int.tryParse(brut);
    if (montant == null || montant <= 0) return l10n.nouvellePiecePrixIncorrect;
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

class _BarreEtapes extends StatelessWidget {
  const _BarreEtapes({required this.etape});

  final int etape;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p12,
        AppSpacing.p20,
        0,
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.p8),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                decoration: BoxDecoration(
                  color: i <= etape
                      ? ClosetColors.vert
                      : ClosetColors.fond300.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EtapePhotos extends StatelessWidget {
  const _EtapePhotos({
    required this.medias,
    required this.aide,
    required this.onPrendre,
    required this.onFilmer,
    required this.onImporter,
    required this.onRetirer,
  });

  final List<XFile> medias;
  final String aide;
  final VoidCallback onPrendre;
  final VoidCallback onFilmer;
  final VoidCallback onImporter;
  final ValueChanged<int> onRetirer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(aide, style: ClosetTextStyles.corps.copyWith(
          color: ClosetColors.neutre700,
        )),
        const SizedBox(height: AppSpacing.p16),
        _ZoneDepotPhotos(
          medias: medias,
          onPrendre: onPrendre,
          onFilmer: onFilmer,
          onImporter: onImporter,
          onRetirer: onRetirer,
        ),
      ],
    );
  }
}

class _EtapeType extends StatelessWidget {
  const _EtapeType({
    required this.types,
    required this.choisi,
    required this.onChoix,
  });

  final List<String> types;
  final String? choisi;
  final ValueChanged<String> onChoix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClosetSurtitre(ClosetL10n.of(context).depotEtapeType),
        const SizedBox(height: AppSpacing.p12),
        Wrap(
          spacing: AppSpacing.p8,
          runSpacing: AppSpacing.p8,
          children: [
            for (final type in types)
              ClosetChip(
                label: type,
                isActive: type == choisi,
                onTap: () => onChoix(type),
              ),
          ],
        ),
      ],
    );
  }
}

class _EtapeDetails extends StatelessWidget {
  const _EtapeDetails({
    required this.marque,
    required this.maisons,
    required this.taille,
    required this.etat,
    required this.prix,
    required this.onTaille,
    required this.onEtat,
  });

  final TextEditingController marque;
  final List<String> maisons;
  final String? taille;
  final String etat;
  final TextEditingController prix;
  final ValueChanged<String> onTaille;
  final ValueChanged<String> onEtat;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChampMarque(controller: marque, suggestions: maisons),
        const SizedBox(height: AppSpacing.p24),
        ClosetSurtitre(l10n.tailleLabel),
        const SizedBox(height: AppSpacing.p12),
        Wrap(
          spacing: AppSpacing.p8,
          runSpacing: AppSpacing.p8,
          children: [
            for (final t in taillesArticle)
              ClosetChip(
                label: t,
                isActive: t == taille,
                onTap: () => onTaille(t),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.p24),
        ClosetSurtitre(l10n.etatPiece),
        const SizedBox(height: AppSpacing.p12),
        Wrap(
          spacing: AppSpacing.p8,
          runSpacing: AppSpacing.p8,
          children: [
            for (final e in etatsPiecePour(l10n))
              ClosetChip(
                label: e.$2,
                isActive: e.$1 == etat,
                onTap: () => onEtat(e.$1),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.p24),
        _Champ(
          label: l10n.nouvellePiecePrixSouhaite,
          hint: '30.000',
          controller: prix,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (v) => _SourceurNouvellePieceScreenState._validerPrix(v, l10n),
          inputFormatters: const [_SeparateurMilliers()],
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
    final l10n = ClosetL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nouvellePieceMarque,
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
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
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
    final l10n = ClosetL10n.of(context);
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
                ? l10n.nouvellePieceMediasVide
                : l10n.nouvellePieceMediasAjoutes(medias.length),
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
                  label: l10n.nouvellePiecePhoto,
                  plein: false,
                  onTap: onPrendre,
                ),
              ),
              const SizedBox(width: AppSpacing.p8),
              Expanded(
                child: _BoutonPhoto(
                  label: l10n.nouvellePieceVideo,
                  plein: false,
                  onTap: onFilmer,
                ),
              ),
              const SizedBox(width: AppSpacing.p8),
              Expanded(
                child: _BoutonPhoto(
                  label: l10n.nouvellePieceImporter,
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
            label: ClosetL10n.of(context).nouvellePieceRetirerMedia,
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
