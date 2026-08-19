import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/sourceur_repository.dart';
import 'widgets/labeled_field.dart';
import 'widgets/sourceur_hero_card.dart';
import 'widgets/step_indicator.dart';

/// Parcours d'inscription « Devenir Sourceur » en 3 étapes
class SourceurInscriptionScreen extends ConsumerStatefulWidget {
  const SourceurInscriptionScreen({super.key});

  @override
  ConsumerState<SourceurInscriptionScreen> createState() =>
      _SourceurInscriptionScreenState();
}

class _SourceurInscriptionScreenState
    extends ConsumerState<SourceurInscriptionScreen> {
  static const _specialites = [
    'Robes',
    'Vestes',
    'Sacs',
    'Accessoires',
    'Multi-univers',
  ];
  static const _moyensPaiement = ['MTN MoMo', 'Orange Money', 'Virement bancaire'];

  final _scrollController = ScrollController();
  bool _isLoading = false;

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

  Future<void> _rejoindreLeCercle() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read<SourceurRepository>(sourceurRepositoryProvider);
      await repo.inscrire(SourceurInscriptionData(
        nomAtelier: _atelierController.text.trim(),
        ville: _villeController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        univers: _universController.text.trim(),
        specialite: _specialite,
        moyenPaiement: _moyenPaiement,
        numeroPaiement: _numeroController.text.trim(),
      ));
      if (!mounted) return;
      setState(() => _isLoading = false);
      await dialogueSucces(
        context,
        titre: 'Adhésion transmise',
        message: 'Votre fiche d’adhésion a bien été envoyée.',
      );
      if (!mounted) return;
      context.go('/sourceur/adhesion');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await dialogueErreur(context, e, titre: 'Adhésion impossible');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SourceurHeroCard(),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: StepIndicator(
                        etapeCourante: _etape,
                        labels: const ['ATELIER', 'UNIVERS', 'PAIEMENT'],
                      ),
                    ),
                    const SizedBox(height: 24),
                    switch (_etape) {
                      0 => _buildEtapeAtelier(),
                      1 => _buildEtapeUnivers(),
                      _ => _buildEtapePaiement(),
                    },
                    const SizedBox(height: 28),
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
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: cs.onSurface.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 13, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          Text('Devenir Sourceur',
              style: ClosetTextStyles.titreEcran.copyWith(
                  fontSize: 16, color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _buildEtapeAtelier() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          icone: Icons.storefront_outlined,
          label: 'Nom de votre atelier',
          controller: _atelierController,
          hint: "L'Atelier d'Awa",
        ),
        const SizedBox(height: 22),
        LabeledField(
          icone: Icons.location_on_outlined,
          label: 'Ville',
          controller: _villeController,
          hint: 'Yaoundé',
        ),
        const SizedBox(height: 22),
        LabeledField(
          icone: Icons.phone_outlined,
          label: 'Téléphone WhatsApp',
          controller: _whatsappController,
          hint: '+237 6 77 45 22 18',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

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
          maxLines: 6,
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Icon(Icons.palette_outlined, size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
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

  Widget _buildEtapePaiement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.handshake_outlined,
                size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
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
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.payments_outlined,
                size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
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
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 14),
        LabeledField(
          icone: Icons.phone_outlined,
          label: 'Numéro',
          controller: _numeroController,
          hint: '+237 6 ...',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 18, color: ClosetColors.vert),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'En rejoignant le cercle, vous acceptez la charte '
                  "d'authenticité ClosET et une commission de 25% "
                  'sur les ventes.',
                  style: ClosetTextStyles.corps,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoutons() {
    final derniereEtape = _etape == 2;
    final bouton = _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: ClosetColors.dore))
        : ClosetPrimaryButton(
            label: derniereEtape ? 'Rejoindre le cercle' : 'Continuer',
            dore: derniereEtape,
            onPressed: _etapeValide
                ? (derniereEtape ? _rejoindreLeCercle : () => _changerEtape(1))
                : null,
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
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selectionne ? ClosetColors.vert : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selectionne ? ClosetColors.vert : cs.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(
                selectionne
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selectionne ? ClosetColors.dore : cs.onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: ClosetTextStyles.saisie.copyWith(
                    color: selectionne
                        ? ClosetColors.texteSurVert
                        : cs.onSurface,
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
