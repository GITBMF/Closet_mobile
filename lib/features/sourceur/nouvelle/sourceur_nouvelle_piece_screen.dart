import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_field.dart';
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
/// état, estimation, puis la zone de dépôt de photos en pointillés.
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
  String _etat = etatsPiece.first;

  @override
  void dispose() {
    _type.dispose();
    _marque.dispose();
    _taille.dispose();
    _prix.dispose();
    super.dispose();
  }

  void _poursuivre() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // TODO(backend): enregistrer l'étape 2 puis enchaîner sur l'étape 3.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Étape suivante bientôt disponible.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Confier une pièce',
              onRetour: () => context.go('/sourceur/espace'),
              actions: [
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
                      ClosetChampLibelle(
                        label: 'Type d’article',
                        controller: _type,
                        hint: 'Veste',
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
                            child: ClosetChampLibelle(
                              label: 'Marque (Si connue)',
                              controller: _marque,
                              hint: 'Lin & Co',
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.p20),
                          Expanded(
                            child: ClosetChampLibelle(
                              label: 'Taille',
                              controller: _taille,
                              hint: 'M',
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
                      ClosetChampLibelle(
                        label: 'Prix souhaité',
                        controller: _prix,
                        hint: '30.000 FCFA',
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
                      const _ZoneDepotPhotos(),
                      const SizedBox(height: AppSpacing.p24),
                      Center(
                        child: SizedBox(
                          width: 312,
                          height: 44,
                          child: Material(
                            color: ClosetColors.vert,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cercle),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cercle),
                              onTap: _poursuivre,
                              child: Center(
                                child: Text(
                                  'Poursuivre',
                                  style: ClosetTextStyles.libelleFort.copyWith(
                                    color: Colors.white,
                                  ),
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

/// Zone de dépôt : cadre de 350 × 230 (rayon 16) bordé de gris, vignette
/// verte de 80 et deux boutons de 153 × 44.
class _ZoneDepotPhotos extends StatelessWidget {
  const _ZoneDepotPhotos();

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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Text(
            'Ajoutez une photo pour mettre votre pièce en valeur.',
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
                  onTap: () => _aVenir(context),
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: _BoutonPhoto(
                  label: 'Importer',
                  plein: true,
                  onTap: () => _aVenir(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _aVenir(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajout de photo bientôt disponible.')),
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
        color: plein ? ClosetColors.vert : Colors.white,
        borderRadius: rayon,
        shape: plein
            ? null
            : RoundedRectangleBorder(
                borderRadius: rayon,
                side: const BorderSide(
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
                color: plein ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
