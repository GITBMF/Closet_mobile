import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/champ_telephone.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';
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
  /// Codes stables (indépendants de la langue) envoyés au backend / comparés
  /// en logique — les libellés affichés viennent de [ClosetL10n].
  static const _specialiteCodes = ['robes', 'vestes', 'sacs', 'accessoires', 'multi'];
  static const _moyenCodes = ['mtn_momo', 'orange_money', 'virement_bancaire'];
  static const _collaborationCodes = ['consignment', 'direct_sale'];

  List<String> _specialiteLabels(ClosetL10n l10n) => [
        l10n.specialiteRobes,
        l10n.specialiteVestes,
        l10n.specialiteSacs,
        l10n.specialiteAccessoires,
        l10n.specialiteMultiUnivers,
      ];

  List<String> _moyenLabels(ClosetL10n l10n) =>
      [l10n.moyenMtnMomo, l10n.moyenOrangeMoney, l10n.moyenVirementBancaire];

  List<String> _collaborationLabels(ClosetL10n l10n) =>
      [l10n.collabDepotVente, l10n.collabVenteDirecte];

  final _scrollController = ScrollController();
  bool _isLoading = false;

  // Étape 1 — Atelier
  final _atelierController = TextEditingController();
  final _villeController = TextEditingController();
  final _whatsapp = TelephoneController();

  // Étape 2 — Univers
  final _universController = TextEditingController();
  String? _specialite;

  // Étape 3 — Paiement
  String _typeCollaboration = _collaborationCodes.first;
  String _moyenPaiement = _moyenCodes.first;
  final _numero = TelephoneController();

  int _etape = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _atelierController.dispose();
    _villeController.dispose();
    _whatsapp.dispose();
    _universController.dispose();
    _numero.dispose();
    super.dispose();
  }

  bool get _etapeValide => switch (_etape) {
        0 => _atelierController.text.trim().isNotEmpty &&
            _villeController.text.trim().isNotEmpty &&
            _whatsapp.estValide,
        1 => _universController.text.trim().isNotEmpty && _specialite != null,
        _ => _moyenPaiement == 'virement_bancaire'
            ? _numero.national.text.trim().isNotEmpty
            : _numero.estValide,
      };

  void _changerEtape(int delta) {
    setState(() => _etape = (_etape + delta).clamp(0, 2));
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _retour() {
    if (_etape > 0) {
      _changerEtape(-1);
      return;
    }
    sourceurRetour(context, repli: '/sourceur/devenir');
  }

  Future<void> _rejoindreLeCercle() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read<SourceurRepository>(sourceurRepositoryProvider);
      await repo.inscrire(SourceurInscriptionData(
        nomAtelier: _atelierController.text.trim(),
        ville: _villeController.text.trim(),
        whatsapp: _whatsapp.e164,
        univers: _universController.text.trim(),
        specialite: _specialite,
        moyenPaiement: _moyenPaiement,
        numeroPaiement: _numero.e164.isNotEmpty
            ? _numero.e164
            : _numero.national.text.trim(),
        typeCollaboration: _typeCollaboration,
      ));
      if (!mounted) return;
      final l10n = ClosetL10n.of(context);
      setState(() => _isLoading = false);
      await dialogueSucces(
        context,
        titre: l10n.adhesionTransmiseTitre,
        message: l10n.adhesionTransmiseCorps,
      );
      if (!mounted) return;
      context.go('/sourceur/adhesion');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await dialogueErreur(context, e, titre: ClosetL10n.of(context).adhesionImpossibleTitre);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ClosetL10n.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _retour();
      },
      child: Scaffold(
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
                        labels: [l10n.etapeAtelier, l10n.etapeUnivers, l10n.etapePaiement],
                      ),
                    ),
                    const SizedBox(height: 24),
                    switch (_etape) {
                      0 => _buildEtapeAtelier(l10n),
                      1 => _buildEtapeUnivers(l10n),
                      _ => _buildEtapePaiement(l10n),
                    },
                    const SizedBox(height: 28),
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _atelierController,
                        _villeController,
                        _whatsapp,
                        _universController,
                        _numero,
                      ]),
                      builder: (_, _) => _buildBoutons(l10n),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ClosetL10n.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: cs.onSurface.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.retour,
            onPressed: _retour,
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(l10n.devenirSourceur,
              style: ClosetTextStyles.titreEcran.copyWith(
                  fontSize: 16, color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _buildEtapeAtelier(ClosetL10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          icone: Icons.storefront_outlined,
          label: l10n.sourceurNomAtelier,
          controller: _atelierController,
          hint: l10n.sourceurAtelierHint,
        ),
        const SizedBox(height: 22),
        LabeledField(
          icone: Icons.location_on_outlined,
          label: l10n.villeSimple,
          controller: _villeController,
          hint: 'Yaoundé',
        ),
        const SizedBox(height: 22),
        ChampTelephone(
          icone: Icons.phone_outlined,
          label: l10n.sourceurTelephoneWhatsapp,
          controller: _whatsapp,
          hint: '6 77 45 22 18',
          style: StyleChampTelephone.sourceur,
          validerAvecLeFormulaire: false,
        ),
      ],
    );
  }

  Widget _buildEtapeUnivers(ClosetL10n l10n) {
    final labels = _specialiteLabels(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          icone: Icons.description_outlined,
          label: l10n.universDetailLabel,
          controller: _universController,
          hint: l10n.universDetailHint,
          maxLines: 6,
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Icon(Icons.palette_outlined, size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
            Text(l10n.specialiteLabel, style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < _specialiteCodes.length; i++)
              ClosetChip(
                label: labels[i],
                selectionnee: _specialite == _specialiteCodes[i],
                onTap: () => setState(() => _specialite = _specialiteCodes[i]),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEtapePaiement(ClosetL10n l10n) {
    final collaborationLabels = _collaborationLabels(l10n);
    final moyenLabels = _moyenLabels(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.handshake_outlined,
                size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
            Text(l10n.typeCollaborationLabel, style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _collaborationCodes.length; i++) ...[
          _PaiementOption(
            label: collaborationLabels[i],
            selectionne: _typeCollaboration == _collaborationCodes[i],
            onTap: () => setState(() => _typeCollaboration = _collaborationCodes[i]),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.payments_outlined,
                size: 16, color: ClosetColors.dore),
            const SizedBox(width: 8),
            Text(l10n.moyenRemunerationLabel, style: ClosetTextStyles.labelChamp),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _moyenCodes.length; i++) ...[
          _PaiementOption(
            label: moyenLabels[i],
            selectionne: _moyenPaiement == _moyenCodes[i],
            onTap: () => setState(() => _moyenPaiement = _moyenCodes[i]),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 14),
        ChampTelephone(
          icone: Icons.phone_outlined,
          label: l10n.numeroLabel,
          controller: _numero,
          hint: '6 90 12 34 56',
          style: StyleChampTelephone.sourceur,
          validerAvecLeFormulaire: false,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.conditionsAdhesionTitre,
                style: ClosetTextStyles.titreBloc,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.conditionsAdhesionCorps,
                style: ClosetTextStyles.corps,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoutons(ClosetL10n l10n) {
    final derniereEtape = _etape == 2;
    final bouton = _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: ClosetColors.dore))
        : ClosetPrimaryButton(
            label: derniereEtape ? l10n.rejoindreLeCercle : l10n.continuer,
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
            label: l10n.retour,
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
