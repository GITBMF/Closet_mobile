import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// États proposés par la maquette `33:1389`.
const List<String> etatsPiece = [
  'Neuf',
  'Très bon état',
  'Bon état',
  'Etat correcte',
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
  final _type = TextEditingController();
  final _marque = TextEditingController();
  final _taille = TextEditingController();
  final _prix = TextEditingController();
  final _picker = ImagePicker();

  String _etat = etatsPiece.first;
  XFile? _photo;
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _type.dispose();
    _marque.dispose();
    _taille.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) setState(() => _photo = image);
    } catch (_) {
      if (!mounted) return;
      toastErreur(ref, 'Impossible d’accéder aux photos.');
    }
  }

  Future<void> _poursuivre() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_photo == null) {
      toastInfo(ref, 'Photo manquante', 'Ajoutez une photo de votre pièce.');
      return;
    }

    setState(() => _envoiEnCours = true);

    final piece = PieceDeposee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _type.text.trim(),
      univers: _marque.text.trim().isEmpty
          ? _type.text.trim()
          : _marque.text.trim(),
      prix: _prixSaisi,
      // TODO(backend): téléverser la photo et stocker l'URL renvoyée.
      imageUrl: _photo?.path,
      statut: StatutPiece.enRevue,
    );

    try {
      final id = await ClosetDialogue.executer(
        context,
        message: 'Dépôt en cours…',
        action: () => ref
            .read<SourceurRepository>(sourceurRepositoryProvider)
            .deposerPiece(piece),
      );
      if (!mounted || id == null) return;
      setState(() => _envoiEnCours = false);

      unawaited(HapticFeedback.mediumImpact());
      await dialogueSucces(
        context,
        titre: 'Pièce reçue',
        message:
            'Votre pièce « ${piece.nom} » est en cours d’examen.',
      );
      if (!mounted) return;
      context.go('/sourceur/piece/$id');
    } catch (e) {
      if (!mounted) return;
      await dialogueErreur(context, e, titre: 'Dépôt impossible');
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Confier une pièce',
              onRetour: () => context.go('/sourceur/espace'),
              actions: [
                // Compteur transcrit tel quel de `33:1460`. La maquette ne
                // dessine aucun autre écran portant un compteur : ni les étapes
                // 1, 3 et 4, ni un badge sur l'inspection (`34:1534`) ou le
                // suivi (`34:1710`). Question ouverte côté design plutôt
                // qu'écart de code — voir le rapport final.
                Text(
                  'Etape 2/4',
                  style: ClosetTextStyles.actionPetite.copyWith(
                    letterSpacing: -0.20,
                    color: ClosetColors.fond300,
                  ),
                ),
              ],
            ),
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
                      const _SousTitreSection('Spécificité de la pièce'),
                      const SizedBox(height: AppSpacing.p20),
                      _Champ(
                        label: 'Type d’article',
                        hint: 'Veste',
                        controller: _type,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Précisez le type d’article.'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Champ(
                              label: 'Marque (Si connue)',
                              hint: 'Lin & Co',
                              controller: _marque,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.p20),
                          Expanded(
                            child: _Champ(
                              label: 'Taille',
                              hint: 'M',
                              controller: _taille,
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Indiquez la taille.'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      const _SousTitreSection('état de la pièce'),
                      const SizedBox(height: AppSpacing.p20),
                      Wrap(
                        spacing: AppSpacing.p12,
                        runSpacing: AppSpacing.p16,
                        children: [
                          for (final etat in etatsPiece)
                            ClosetChip(
                              label: etat,
                              isActive: etat == _etat,
                              onTap: () => setState(() => _etat = etat),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      const _SousTitreSection('Estimation'),
                      const SizedBox(height: AppSpacing.p20),
                      _Champ(
                        label: 'Prix souhaité',
                        hint: '30.000 FCFA',
                        controller: _prix,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: _validerPrix,
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      Text(
                        'Clos ET valorise chaque pièce selon ses critères de '
                        'qualité et d’élégance.',
                        style: ClosetTextStyles.labelChamp.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ClosetColors.neutre700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      const _SousTitreSection('Storytelling visuel'),
                      const SizedBox(height: AppSpacing.p20),
                      _ZoneDepotPhotos(
                        photo: _photo,
                        onPrendre: () => _choisirPhoto(ImageSource.camera),
                        onImporter: () => _choisirPhoto(ImageSource.gallery),
                        onRetirer: () => setState(() => _photo = null),
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

/// Sur-titre de section : Lato 500 / 10, `ls 0.30`, doré.
class _SousTitreSection extends StatelessWidget {
  const _SousTitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: ClosetTextStyles.actionPetite.copyWith(
        letterSpacing: 0.30,
        color: ClosetColors.fond400,
      ),
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
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

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
          style: ClosetTextStyles.saisie.copyWith(color: ClosetColors.noir),
          cursorColor: ClosetColors.vert,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ClosetTextStyles.saisie.copyWith(
              color: ClosetColors.placeholderGris,
            ),
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

/// Zone de dépôt : cadre de 230 (rayon 16), vignette de 80 et deux boutons.
///
/// Une fois la photo choisie, la vignette montre le cliché réel avec un
/// bouton de retrait.
class _ZoneDepotPhotos extends StatelessWidget {
  const _ZoneDepotPhotos({
    required this.photo,
    required this.onPrendre,
    required this.onImporter,
    required this.onRetirer,
  });

  final XFile? photo;
  final VoidCallback onPrendre;
  final VoidCallback onImporter;
  final VoidCallback onRetirer;

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: photo == null
                      ? const ColoredBox(
                          color: ClosetColors.vert,
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 30,
                            color: ClosetColors.blanc,
                          ),
                        )
                      : Image.file(File(photo!.path), fit: BoxFit.cover),
                ),
              ),
              if (photo != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Semantics(
                    button: true,
                    label: 'Retirer la photo',
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
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(
            photo == null
                ? 'Ajoutez une photo pour mettre votre pièce en valeur.'
                : 'Photo ajoutée. Vous pouvez la remplacer.',
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
                  label: 'Prendre une photo',
                  plein: false,
                  onTap: onPrendre,
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
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
