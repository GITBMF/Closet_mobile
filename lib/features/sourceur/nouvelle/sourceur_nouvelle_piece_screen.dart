import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../inscription/widgets/labeled_field.dart';
import '../widgets/sourceur_app_bar.dart';

/// Formulaire de dépôt d'une nouvelle pièce (/sourceur/nouvelle) :
/// photos, nom, univers, marque, taille, état, prix et description.
class SourceurNouvellePieceScreen extends ConsumerStatefulWidget {
  const SourceurNouvellePieceScreen({super.key});

  @override
  ConsumerState<SourceurNouvellePieceScreen> createState() =>
      _SourceurNouvellePieceScreenState();
}

class _SourceurNouvellePieceScreenState
    extends ConsumerState<SourceurNouvellePieceScreen> {
  static const _univers = ['Robes', 'Vestes', 'Sacs', 'Chaussures',
      'Accessoires'];
  static const _tailles = ['XS', 'S', 'M', 'L', 'XL', 'Unique'];
  static const _etats = [
    'Neuf avec étiquette',
    'Excellent état',
    'Très bon état',
    'Bon état',
  ];

  final _nomController = TextEditingController();
  final _marqueController = TextEditingController();
  final _prixController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _universChoisi = _univers.first;
  String _taille = 'M';
  String _etat = 'Excellent état';

  final List<XFile?> _photos = [null, null, null];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomController.dispose();
    _marqueController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _formulaireValide =>
      _nomController.text.trim().isNotEmpty &&
      _marqueController.text.trim().isNotEmpty &&
      _prixController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _photos.any((p) => p != null);

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos[index] = image;
      });
    }
  }

  void _supprimerImage(int index) {
    setState(() {
      _photos[index] = null;
    });
  }

  void _envoyerAuComite() {
    final repo = ref.read<SourceurRepository>(sourceurRepositoryProvider);
    final nouvellePiece = PieceDeposee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _nomController.text.trim(),
      univers: _universChoisi,
      prix: double.tryParse(_prixController.text.trim()) ?? 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500',
      statut: StatutPiece.enRevue,
    );
    repo.deposerPiece(nouvellePiece);

    HapticFeedback.mediumImpact();
    context.go('/sourceur/pieces');

    // Déclenche un bandeau de notification 4 secondes plus tard
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        ref.read<NotificationNotifier>(notificationProvider.notifier).show(
          'Pièce reçue',
          'Votre pièce "${nouvellePiece.nom}" est bien en cours d\'examen par notre comité de sélection.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const SourceurAppBar(
        title: 'Nouvelle pièce',
        subtitle: 'DÉPÔT',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.p20, AppSpacing.p8, AppSpacing.p20, AppSpacing.p32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotographies(),
            const SizedBox(height: AppSpacing.p24),
            LabeledField(
              label: 'Nom de la pièce',
              controller: _nomController,
              hint: 'Robe soie ivoire',
            ),
            const SizedBox(height: AppSpacing.p24),
            _buildUnivers(),
            const SizedBox(height: AppSpacing.p24),
            LabeledField(
              icone: Icons.local_offer_outlined,
              label: 'Maison / Marque',
              controller: _marqueController,
              hint: 'Céline, Hermès, Sézane...',
            ),
            const SizedBox(height: AppSpacing.p24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ChampDeroulant(
                    icone: Icons.straighten_outlined,
                    label: 'Taille',
                    valeur: _taille,
                    options: _tailles,
                    onChanged: (v) => setState(() => _taille = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.p16),
                Expanded(
                  child: _ChampDeroulant(
                    icone: Icons.auto_awesome,
                    label: 'État',
                    valeur: _etat,
                    options: _etats,
                    onChanged: (v) => setState(() => _etat = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.p24),
            LabeledField(
              icone: Icons.account_balance_wallet_outlined,
              label: 'Prix proposé (FCFA)',
              controller: _prixController,
              hint: '45000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.p24),
            LabeledField(
              label: 'Description & storytelling',
              controller: _descriptionController,
              hint: 'Portée deux fois, couture impeccable, matière noble...',
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.p32),
            ListenableBuilder(
              listenable: Listenable.merge([
                _nomController,
                _marqueController,
                _prixController,
                _descriptionController,
              ]),
              builder: (_, _) => ClosetPrimaryButton(
                label: 'Envoyer au comité',
                dore: true,
                onPressed: _formulaireValide ? _envoyerAuComite : null,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Réponse sous 48h ouvrées',
                style: ClosetTextStyles.corps.copyWith(
                  fontSize: 14,
                  color: ClosetColors.texteSecondaire,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // -------------------------------------------------------- Photographies

  Widget _buildPhotographies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera_outlined,
                size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
            Text('PHOTOGRAPHIES', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '3 vues minimum : face, dos, détails. Fond neutre, '
          'lumière naturelle.',
          style: ClosetTextStyles.corps.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.p16),
              Expanded(
                child: _EmplacementPhoto(
                  fichier: _photos[i],
                  onTap: () => _pickImage(i),
                  onDelete: () => _supprimerImage(i),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------- Univers

  Widget _buildUnivers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UNIVERS', style: ClosetTextStyles.labelChamp),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final u in _univers)
              ClosetChip(
                label: u,
                selectionnee: _universChoisi == u,
                onTap: () => setState(() => _universChoisi = u),
              ),
          ],
        ),
      ],
    );
  }
}

/// Emplacement de photo en arche avec bordure pleine et « + ».
class _EmplacementPhoto extends StatelessWidget {
  const _EmplacementPhoto({
    required this.onTap,
    this.fichier,
    this.onDelete,
  });

  final VoidCallback onTap;
  final XFile? fichier;
  final VoidCallback? onDelete;

  static const _forme = BorderRadius.vertical(
    top: Radius.circular(32),
    bottom: Radius.circular(16),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content;
    if (fichier != null) {
      content = Stack(
        key: const ValueKey('photo_filled'),
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: _forme,
            child: Image.file(
              File(fichier!.path),
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: Semantics(
              button: true,
              label: 'Supprimer la photo',
              child: Tooltip(
                message: 'Supprimer',
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: AppSpacing.minTouchTarget,
                    height: AppSpacing.minTouchTarget,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    child: Icon(Icons.close, size: 18, color: theme.colorScheme.surface),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      content = DecoratedBox(
        key: const ValueKey('photo_empty'),
        decoration: BoxDecoration(
          borderRadius: _forme,
          border: Border.all(color: ClosetColors.ligne, width: 1.5),
        ),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: _forme,
          child: InkWell(
            borderRadius: _forme,
            onTap: onTap,
            child: SizedBox(
              height: 170,
              child: Icon(Icons.add, size: 24, color: theme.colorScheme.onSurface),
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: content,
    );
  }
}

/// Liste déroulante CLOSET : label doré avec icône puis champ crème arrondi.
class _ChampDeroulant extends StatelessWidget {
  const _ChampDeroulant({
    required this.icone,
    required this.label,
    required this.valeur,
    required this.options,
    required this.onChanged,
  });

  final IconData icone;
  final String label;
  final String valeur;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 16, color: ClosetColors.dore),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: ClosetTextStyles.labelChamp,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ClosetColors.bordure),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valeur,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                style: ClosetTextStyles.saisie.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.symmetric(vertical: 6),
                items: [
                  for (final o in options)
                    DropdownMenuItem(value: o, child: Text(o)),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
