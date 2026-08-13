import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_app_bar.dart';
import '../../core/widgets/closet_sections.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../cliente/selection/selection_screen.dart';
import '../sourceur/retrait/methode_retrait_sheet.dart';
import '../sourceur/widgets/sourceur_header.dart';
import '../transaction/transaction_models.dart';

/// Finalisation de la sélection — transcription de la maquette `56:11462`.
///
/// Étape 1 sur 3 du parcours d'achat : coordonnées de livraison puis moyen
/// de paiement. Les étapes 2 et 3 sont assurées par le tunnel de transaction
/// (`/transaction`), qui produit le reçu.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  String _moyen = moyensRetrait.first.id;
  bool _coordonneesValidees = false;

  @override
  void initState() {
    super.initState();
    final ClosetUser? user = ref.read<ClosetUser?>(currentUserProvider);
    if (user != null) {
      _nom.text = '${user.firstName} ${user.lastName}'.trim();
    }
  }

  @override
  void dispose() {
    _nom.dispose();
    _telephone.dispose();
    super.dispose();
  }

  void _validerCoordonnees() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _coordonneesValidees = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informations de livraison enregistrées.')),
    );
  }

  void _poursuivre() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final total = ref.read(cartTotalProvider) + fraisLivraison;
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre sélection est vide.')),
      );
      return;
    }

    MoyenRetrait moyen = moyensRetrait.first;
    for (final m in moyensRetrait) {
      if (m.id == _moyen) moyen = m;
    }

    context.push(
      '/transaction',
      extra: DemandeTransaction(
        type: TypeOperation.paiement,
        montant: total,
        moyen: moyen.libelle,
        compte: moyen.compte,
        beneficiaire: _nom.text.trim(),
        note: _telephone.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider) + fraisLivraison;

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Ma sélection',
              surtitre: 'finaliser ma commande',
              onRetour: () => context.pop(),
              actions: [
                Text(
                  'Etape 1/3',
                  style: ClosetTextStyles.actionPetite.copyWith(
                    letterSpacing: -0.20,
                    color: ClosetColors.fond300,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.p24,
                    AppSpacing.p20,
                    AppSpacing.p24,
                    AppSpacing.p24,
                  ),
                  children: [
                    const _FriseEtapes(etapeCourante: 1),
                    const SizedBox(height: AppSpacing.p32),
                    const ClosetEnTeteSection(titre: 'Détails de livraison'),
                    const SizedBox(height: AppSpacing.p4),
                    const ClosetSurtitre('veuillez entrer vos informations'),
                    const SizedBox(height: AppSpacing.p20),
                    _Champ(
                      label: 'Nom complet',
                      hint: 'Aïcha N.',
                      controller: _nom,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Indiquez votre nom complet.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    _Champ(
                      label: 'Téléphone (Whatsapp)',
                      hint: '+237 6 90 12 34 56',
                      controller: _telephone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: _validerTelephone,
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      'Nous vous écrirons sur WhatsApp pour suivre votre '
                      'pièce.',
                      style: ClosetTextStyles.meta.copyWith(
                        color: ClosetColors.taupe,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    _BoutonSecondaire(
                      label: _coordonneesValidees
                          ? 'Informations validées'
                          : 'Valider les informations',
                      valide: _coordonneesValidees,
                      onTap: _validerCoordonnees,
                    ),
                    const SizedBox(height: AppSpacing.p32),
                    const ClosetEnTeteSection(titre: 'Méthode de paiement'),
                    const SizedBox(height: AppSpacing.p4),
                    const ClosetSurtitre('veuillez choisir la méthode'),
                    const SizedBox(height: AppSpacing.p16),
                    for (final m in moyensRetrait)
                      _LignePaiement(
                        moyen: m,
                        choisi: m.id == _moyen,
                        onTap: () => setState(() => _moyen = m.id),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(39, 0, 39, AppSpacing.p12),
              child: SizedBox(
                height: 44,
                child: Material(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: _poursuivre,
                    child: Center(
                      child: Text(
                        'Poursuivre - Paiement ${formatPrixFcfa(total)}',
                        style: ClosetTextStyles.bouton.copyWith(
                          fontWeight: FontWeight.w600,
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
    );
  }

  /// Numéro camerounais ou international : au moins 9 chiffres.
  static String? _validerTelephone(String? v) {
    final chiffres = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (chiffres.isEmpty) return 'Indiquez un numéro WhatsApp.';
    if (chiffres.length < 9) return 'Ce numéro semble incomplet.';
    return null;
  }
}

/// Frise horizontale « livraison 1 · Paiement 2 · confirmation 3 ».
class _FriseEtapes extends StatelessWidget {
  const _FriseEtapes({required this.etapeCourante});

  final int etapeCourante;

  static const _etapes = ['livraison', 'Paiement', 'confirmation'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _etapes.length; i++) ...[
          _Pastille(
            numero: i + 1,
            label: _etapes[i],
            atteinte: i + 1 <= etapeCourante,
          ),
          if (i < _etapes.length - 1)
            Expanded(
              child: Container(
                height: AppStroke.moyen,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
                color: i + 1 < etapeCourante
                    ? ClosetColors.vert
                    : ClosetColors.ligne,
              ),
            ),
        ],
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.numero,
    required this.label,
    required this.atteinte,
  });

  final int numero;
  final String label;
  final bool atteinte;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: atteinte ? ClosetColors.vert : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: atteinte ? ClosetColors.vert : ClosetColors.ligne,
              width: AppStroke.moyen,
            ),
          ),
          child: Text(
            '$numero',
            style: ClosetTextStyles.corps.copyWith(
              color: atteinte ? Colors.white : ClosetColors.taupe,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p4),
        Text(
          label,
          style: ClosetTextStyles.meta.copyWith(
            color: atteinte ? ClosetColors.vert : ClosetColors.taupe,
          ),
        ),
      ],
    );
  }
}

/// Champ du formulaire de livraison : libellé vert, zone blanche cerclée d'or.
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
            fillColor: Colors.white,
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

class _BoutonSecondaire extends StatelessWidget {
  const _BoutonSecondaire({
    required this.label,
    required this.valide,
    required this.onTap,
  });

  final String label;
  final bool valide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return SizedBox(
      height: 44,
      child: Material(
        color: valide ? ClosetColors.emeraude100 : Colors.transparent,
        borderRadius: rayon,
        shape: RoundedRectangleBorder(
          borderRadius: rayon,
          side: const BorderSide(
            color: ClosetColors.vert,
            width: AppStroke.fin,
          ),
        ),
        child: InkWell(
          borderRadius: rayon,
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (valide) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: ClosetColors.vert,
                  ),
                  const SizedBox(width: AppSpacing.p8),
                ],
                Text(
                  label,
                  style: ClosetTextStyles.bouton.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ligne de moyen de paiement, alignée sur celle du retrait sourceur.
class _LignePaiement extends StatelessWidget {
  const _LignePaiement({
    required this.moyen,
    required this.choisi,
    required this.onTap,
  });

  final MoyenRetrait moyen;
  final bool choisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: choisi,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.p12),
          padding: const EdgeInsets.all(AppSpacing.p12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.carte),
            border: Border.all(
              color: choisi ? ClosetColors.vert : ClosetColors.fond300,
              width: choisi ? AppStroke.moyen : AppStroke.fin,
            ),
          ),
          child: Row(
            children: [
              Icon(moyen.icone, size: 20, color: ClosetColors.vert),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Text(
                  moyen.libelle,
                  style: ClosetTextStyles.libelle,
                ),
              ),
              Icon(
                choisi
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: choisi ? ClosetColors.vert : ClosetColors.ligne,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
