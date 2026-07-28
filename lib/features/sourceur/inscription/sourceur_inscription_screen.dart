import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_bottom_nav.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_header.dart';
import '../atelier/sourceur_atelier_screen.dart';
import 'widgets/labeled_field.dart';
import 'widgets/sourceur_hero_card.dart';
import 'widgets/step_indicator.dart';

/// Parcours d'inscription « Devenir Sourceur » en 3 étapes :
/// 1. Atelier — 2. Univers — 3. Paiement.
class SourceurInscriptionScreen extends StatefulWidget {
  const SourceurInscriptionScreen({super.key});

  @override
  State<SourceurInscriptionScreen> createState() =>
      _SourceurInscriptionScreenState();
}

class _SourceurInscriptionScreenState extends State<SourceurInscriptionScreen> {
  static const _specialites = [
    'Robes',
    'Vestes',
    'Sacs',
    'Accessoires',
    'Multi-univers',
  ];
  static const _moyensPaiement = ['MTN MoMo', 'Orange Money',
      'Virement bancaire'];

  final _scrollController = ScrollController();

  // Étape 1 — Atelier
  final _atelierController = TextEditingController();
  final _villeController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Étape 2 — Univers
  final _universController = TextEditingController();
  String? _specialite;

  // Étape 3 — Paiement
  static const _typesCollaboration = ['Dépôt-vente (commission 25%)', 'Vente directe (achat immédiat)'];
  String _typeCollaboration = _typesCollaboration.first;
  String _moyenPaiement = _moyensPaiement.first;
  final _numeroController = TextEditingController();

  int _etape = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _atelierController.dispose();
    _villeController.dispose();
    _whatsappController.dispose();
    _universController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  bool get _etapeValide => switch (_etape) {
        0 => _atelierController.text.trim().isNotEmpty &&
            _villeController.text.trim().isNotEmpty &&
            _whatsappController.text.trim().isNotEmpty,
        1 => _universController.text.trim().isNotEmpty && _specialite != null,
        _ => _numeroController.text.trim().isNotEmpty,
      };

  void _changerEtape(int delta) {
    setState(() => _etape = (_etape + delta).clamp(0, 2));
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _rejoindreLeCercle() {
    // TODO: brancher l'appel API d'inscription sourceur quand le backend
    // sera disponible.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SourceurAtelierScreen(
          nomAtelier: _atelierController.text.trim(),
          ville: _villeController.text.trim(),
        ),
      ),
    );
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
              titre: 'Devenir Sourceur',
              wishlistCount: 2,
              panierCount: 2,
              notificationsCount: 2,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SourceurHeroCard(),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: StepIndicator(
                        etapeCourante: _etape,
                        labels: const ['ATELIER', 'UNIVERS', 'PAIEMENT'],
                      ),
                    ),
                    const SizedBox(height: 32),
                    switch (_etape) {
                      0 => _buildEtapeAtelier(),
                      1 => _buildEtapeUnivers(),
                      _ => _buildEtapePaiement(),
                    },
                    const SizedBox(height: 36),
                    // Seuls les boutons dépendent du contenu des champs :
                    // on ne reconstruit qu'eux à chaque frappe.
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _atelierController,
                        _villeController,
                        _whatsappController,
                        _universController,
                        _numeroController,
                      ]),
                      builder: (_, _) => _buildBoutons(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClosetBottomNav(indexActif: 1, onTap: (_) {}),
    );
  }

  // ---------------------------------------------------------------- Étape 1

  Widget _buildEtapeAtelier() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          icone: Icons.storefront_outlined,
          label: 'Nom de votre atelier',
          controller: _atelierController,
          hint: "L'Atelier d'Awa",        ),
        const SizedBox(height: 28),
        LabeledField(
          icone: Icons.location_on_outlined,
          label: 'Ville',
          controller: _villeController,
          hint: 'Yaoundé',        ),
        const SizedBox(height: 28),
        LabeledField(
          icone: Icons.phone_outlined,
          label: 'Téléphone WhatsApp',
          controller: _whatsappController,
          hint: '+237 6 77 45 22 18',
          keyboardType: TextInputType.phone,        ),
      ],
    );
  }

  // ---------------------------------------------------------------- Étape 2

  Widget _buildEtapeUnivers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          icone: Icons.description_outlined,
          label: 'Votre univers en quelques mots',
          controller: _universController,
          hint: 'Racontez votre histoire, votre sensibilité, '
              'vos coups de cœur...',
          maxLines: 6,        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Icon(Icons.palette_outlined,
                size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Text('SPÉCIALITÉ', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final s in _specialites)
              ClosetChip(
                label: s,
                selectionnee: _specialite == s,
                onTap: () => setState(() => _specialite = s),
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- Étape 3

  Widget _buildEtapePaiement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.handshake_outlined,
                size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Text('TYPE DE COLLABORATION', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 16),
        for (final type in _typesCollaboration) ...[
          _PaiementOption(
            label: type,
            selectionne: _typeCollaboration == type,
            onTap: () => setState(() => _typeCollaboration = type),
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.payments_outlined,
                size: 20, color: ClosetColors.dore),
            const SizedBox(width: 10),
            Text('MOYEN DE RÉMUNÉRATION', style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 16),
        for (final moyen in _moyensPaiement) ...[
          _PaiementOption(
            label: moyen,
            selectionne: _moyenPaiement == moyen,
            onTap: () => setState(() => _moyenPaiement = moyen),
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 14),
        LabeledField(
          icone: Icons.phone_outlined,
          label: 'Numéro',
          controller: _numeroController,
          hint: '+237 6 ...',
          keyboardType: TextInputType.phone,        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ClosetColors.creme,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ClosetColors.bordure),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 22, color: ClosetColors.vert),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'En rejoignant le cercle, vous acceptez la charte '
                  "d'authenticité Clos ET.",
                  style: ClosetTextStyles.corps,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- Boutons

  Widget _buildBoutons() {
    final derniereEtape = _etape == 2;
    final action = derniereEtape ? _rejoindreLeCercle : () => _changerEtape(1);
    final bouton = ClosetPrimaryButton(
      label: derniereEtape ? 'Rejoindre le cercle' : 'Continuer',
      dore: derniereEtape,
      onPressed: _etapeValide ? action : null,
    );

    if (_etape == 0) return bouton;
    return Row(
      children: [
        Expanded(
          child: ClosetOutlineButton(
            label: 'Retour',
            onPressed: () => _changerEtape(-1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: bouton),
      ],
    );
  }
}

class _PaiementOption extends StatelessWidget {
  const _PaiementOption({
    required this.label,
    required this.selectionne,
    required this.onTap,
  });

  final String label;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selectionne ? ClosetColors.vert : ClosetColors.creme,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selectionne ? ClosetColors.vert : ClosetColors.bordure,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Icon(
                selectionne
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 24,
                color: selectionne ? ClosetColors.dore : ClosetColors.noir,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: ClosetTextStyles.saisie.copyWith(
                    color: selectionne
                        ? ClosetColors.texteSurVert
                        : ClosetColors.noir,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
