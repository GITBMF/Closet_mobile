import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/bordure_pointillee.dart';
import '../../../core/widgets/closet_bottom_nav.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_header.dart';
import '../inscription/widgets/labeled_field.dart';

/// Formulaire de dépôt d'une nouvelle pièce (/sourceur/nouvelle) :
/// photos, nom, univers, marque, taille, état, prix et description.
class SourceurNouvellePieceScreen extends StatefulWidget {
  const SourceurNouvellePieceScreen({super.key});

  @override
  State<SourceurNouvellePieceScreen> createState() =>
      _SourceurNouvellePieceScreenState();
}

class _SourceurNouvellePieceScreenState
    extends State<SourceurNouvellePieceScreen> {
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
      _descriptionController.text.trim().isNotEmpty;

  void _envoyerAuComite() {
    // TODO: brancher l'envoi du dépôt au comité quand le backend
    // sera disponible.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ClosetHeader(
              titre: 'Nouvelle pièce',
              sousTitre: 'Dépôt',
              wishlistCount: 2,
              panierCount: 2,
              notificationsCount: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotographies(),
                    const SizedBox(height: 32),
                    LabeledField(
                      label: 'Nom de la pièce',
                      controller: _nomController,
                      hint: 'Robe soie ivoire',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),
                    _buildUnivers(),
                    const SizedBox(height: 28),
                    LabeledField(
                      icone: Icons.local_offer_outlined,
                      label: 'Maison / Marque',
                      controller: _marqueController,
                      hint: 'Céline, Hermès, Sézane...',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),
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
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 28),
                    LabeledField(
                      icone: Icons.account_balance_wallet_outlined,
                      label: 'Prix proposé (FCFA)',
                      controller: _prixController,
                      hint: '45000',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),
                    LabeledField(
                      label: 'Description & storytelling',
                      controller: _descriptionController,
                      hint: 'Portée deux fois, couture impeccable, '
                          'matière noble...',
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 36),
                    ClosetPrimaryButton(
                      label: 'Envoyer au comité',
                      dore: true,
                      onPressed: _formulaireValide ? _envoyerAuComite : null,
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Réponse sous 48h ouvrées',
                        style: ClosetTextStyles.corps.copyWith(
                          fontSize: 15,
                          color: ClosetColors.texteSecondaire,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClosetBottomNav(indexActif: -1, onTap: (_) {}),
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
                size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Text('PHOTOGRAPHIES', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '3 vues minimum : face, dos, détails. Fond neutre, '
          'lumière naturelle.',
          style: ClosetTextStyles.corps.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: _EmplacementPhoto(onTap: () {
                // TODO: ouvrir le sélecteur de photos (image_picker).
              })),
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

/// Emplacement de photo en arche avec bordure pointillée et « + ».
class _EmplacementPhoto extends StatelessWidget {
  const _EmplacementPhoto({required this.onTap});

  final VoidCallback onTap;

  static const _forme = BorderRadius.vertical(
    top: Radius.circular(70),
    bottom: Radius.circular(24),
  );

  @override
  Widget build(BuildContext context) {
    return BordurePointillee(
      borderRadius: _forme,
      couleur: ClosetColors.dore.withValues(alpha: 0.45),
      child: Material(
        color: ClosetColors.creme.withValues(alpha: 0.6),
        borderRadius: _forme,
        child: InkWell(
          borderRadius: _forme,
          onTap: onTap,
          child: const SizedBox(
            height: 190,
            child: Icon(Icons.add, size: 28, color: ClosetColors.noir),
          ),
        ),
      ),
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
            Icon(icone, size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: ClosetTextStyles.labelChamp,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: ClosetColors.creme,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ClosetColors.bordure),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valeur,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: ClosetColors.noir),
              style: ClosetTextStyles.saisie,
              dropdownColor: ClosetColors.creme,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(vertical: 8),
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
      ],
    );
  }
}
