import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_app_bar.dart';
import '../../core/widgets/closet_sections.dart';
import '../../core/widgets/frise_tunnel.dart';
import '../../core/widgets/toasts.dart';
import '../../data/models/geo.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/geo_repository.dart';
import '../sourceur/widgets/sourceur_header.dart';
import '../transaction/transaction_models.dart';
import 'brouillon_commande.dart';
import 'montants.dart';
import 'moyens_paiement.dart';
import 'widgets/checkout_widgets.dart';

/// Finalisation de la sélection — transcription de la maquette `56:11462`.
///
/// Étape 1 sur 3 du parcours d'achat : coordonnées, adresse de livraison puis
/// moyen de paiement. Les étapes 2 et 3 sont assurées par le tunnel de
/// transaction (`/transaction`), qui produit le reçu.
///
/// La saisie est portée par [brouillonCommandeProvider] et non par l'état local
/// de l'écran : l'exécuteur du tunnel a besoin de l'adresse pour créer la
/// commande, et le récapitulatif de la sélection a besoin de la remise.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();

  @override
  void initState() {
    super.initState();
    final brouillon = ref.read(brouillonCommandeProvider);
    final ClosetUser? user = ref.read<ClosetUser?>(currentUserProvider);

    _nom.text = brouillon.nomComplet.isNotEmpty
        ? brouillon.nomComplet
        : user == null
            ? ''
            : '${user.firstName} ${user.lastName}'.trim();
    _telephone.text = brouillon.telephone;
  }

  @override
  void dispose() {
    _timerTotaux?.cancel();
    _nom.dispose();
    _telephone.dispose();
    _quartier.dispose();
    super.dispose();
  }

  BrouillonCommandeNotifier get _brouillon =>
      ref.read(brouillonCommandeProvider.notifier);

  void _validerCoordonnees() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final brouillon = ref.read(brouillonCommandeProvider);
    if (!brouillon.adresseComplete) {
      _signaler(
        brouillon.mode == ModeAdresse.ville
            ? 'Choisissez votre ville de livraison.'
            : 'Complétez région, département et quartier.',
      );
      return;
    }

    _brouillon.majCoordonnees(
      nomComplet: _nom.text.trim(),
      telephone: _telephone.text.trim(),
    );
    _brouillon.validerCoordonnees();
    _signaler('Informations de livraison enregistrées.');
  }

  Future<void> _choisirVille() async {
    try {
      final villes = await ref.read(villesProvider.future);
      if (!mounted) return;

      final choix = await afficherSelecteur<Ville>(
        context: context,
        titre: 'Ville de livraison',
        options: villes,
        libelle: (v) => v.nom,
        sousTitre: (v) => v.delaiAnnonce,
        selection: ref.read(brouillonCommandeProvider).ville,
      );
      if (choix != null) _brouillon.choisirVille(choix);
    } catch (e) {
      if (mounted) toastErreur(ref, e, titre: 'Villes indisponibles');
    }
  }

  Future<void> _choisirRegion() async {
    try {
      final regions = await ref.read(regionsProvider.future);
      if (!mounted) return;

      final choix = await afficherSelecteur<Region>(
        context: context,
        titre: 'Région',
        options: regions,
        libelle: (r) => r.nom,
        selection: ref.read(brouillonCommandeProvider).region,
      );
      if (choix != null) _brouillon.choisirRegion(choix);
    } catch (e) {
      if (mounted) toastErreur(ref, e, titre: 'Régions indisponibles');
    }
  }

  Future<void> _choisirDepartement() async {
    final region = ref.read(brouillonCommandeProvider).region;
    if (region == null) return;

    try {
      final departements =
          await ref.read(departementsProvider(region.id).future);
      if (!mounted) return;

      final choix = await afficherSelecteur<Departement>(
        context: context,
        titre: 'Département',
        options: departements,
        libelle: (d) => d.nom,
        selection: ref.read(brouillonCommandeProvider).departement,
      );
      if (choix != null) _brouillon.choisirDepartement(choix);
    } catch (e) {
      if (mounted) toastErreur(ref, e, titre: 'Départements indisponibles');
    }
  }

  void _signaler(String message) {
    toastInfo(ref, message);
  }

  void _poursuivre() {
    if (!_recapLivraison) {
      _ouvrirEcranAdresse();
      return;
    }
    if (!_totaux) {
      _ouvrirEcranTotaux();
      return;
    }
    if (!_totauxPrets) return;

    final pieces = ref.read(cartListProvider);
    if (pieces.isEmpty) {
      _signaler('Votre sélection est vide.');
      return;
    }

    final brouillon = ref.read(brouillonCommandeProvider);
    if (!brouillon.adresseComplete) {
      _signaler('Complétez votre adresse de livraison.');
      return;
    }

    final moyen = brouillon.moyen;
    if (moyen == null) {
      _signaler('Choisissez un moyen de paiement.');
      return;
    }
    if (!brouillon.paiementComplet) {
      _signaler('Complétez les informations de paiement.');
      return;
    }

    final devis = ref.read(devisCourantProvider).value;
    final total = ref.read(totalAReglerProvider);
    if (devis == null || total == null) {
      // Zone à devis : la maquette laisse le total « à determiner ». Aucune
      // somme ne peut être prélevée sans montant connu.
      _signaler(
        'La livraison vers cette zone est à devis. Nous vous contacterons '
        'sur WhatsApp pour la confirmer.',
      );
      return;
    }

    // Le nom saisi prime sur celui du compte : la livraison peut être adressée
    // à un tiers.
    _brouillon.majCoordonnees(
      nomComplet: _nom.text.trim(),
      telephone: _telephone.text.trim(),
    );

    context.push(
      '/transaction',
      extra: DemandeTransaction(
        type: TypeOperation.paiement,
        montant: total,
        fraisLivraison: devis.montant,
        moyen: moyen.operateur,
        compte: moyen.saisie == SaisieMoyen.carte
            ? brouillon.numeroCarte
            : brouillon.numeroPaiement,
        beneficiaire: _nom.text.trim(),
        note: _telephone.text.trim(),
        // Corps du reçu de l'acheteuse (`162:3473`) : la pièce achetée, le
        // moyen employé et l'adresse retenue.
        lignesRecu: [
          LigneRecu(
            pieces.length == 1 ? 'Pièce' : 'Pièces',
            pieces.length == 1
                ? pieces.first.title
                : '${pieces.length} pièces',
          ),
          LigneRecu('Moyen de paiement', moyen.libelle),
          LigneRecu('Livraison', brouillon.adresseResumee),
          if (brouillon.remise > 0)
            LigneRecu('Code privilège', '- ${formatPrixFcfa(brouillon.remise)}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brouillon = ref.watch(brouillonCommandeProvider);
    final total = ref.watch(totalAReglerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Ma sélection',
              surtitre: 'Finaliser ma commande',
              onRetour: () => context.pop(),
              actions: [
                Text(
                  'Étape 1/3',
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
                    const FriseTunnel(etapeCourante: 1),
                    const SizedBox(height: AppSpacing.p32),
                    const ClosetEnTeteSection(titre: 'Détails de livraison'),
                    const SizedBox(height: AppSpacing.p4),
                    const ClosetSurtitre('Veuillez entrer vos informations'),
                    const SizedBox(height: AppSpacing.p20),
                    ChampCheckout(
                      label: 'Nom complet',
                      hint: 'Aïcha N.',
                      controller: _nom,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Indiquez votre nom complet.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    ChampCheckout(
                      label: 'Téléphone (WhatsApp)',
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
                    _BlocAdresse(
                      brouillon: brouillon,
                      onVille: _choisirVille,
                      onRegion: _choisirRegion,
                      onDepartement: _choisirDepartement,
                      onQuartier: _brouillon.majQuartier,
                      onMode: _brouillon.choisirMode,
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    BoutonSecondaireCheckout(
                      label: 'Valider les informations',
                      valide: brouillon.coordonneesValidees,
                      onTap: _validerCoordonnees,
                    ),
                    const SizedBox(height: AppSpacing.p32),
                    const ClosetEnTeteSection(titre: 'Méthode de paiement'),
                    const SizedBox(height: AppSpacing.p4),
                    const ClosetSurtitre('Veuillez choisir la méthode'),
                    const SizedBox(height: AppSpacing.p16),
                    for (final m in moyensPaiement)
                      _LignePaiement(
                        moyen: m,
                        choisi: m.id == brouillon.moyen?.id,
                        onTap: () => _brouillon.choisirMoyen(m),
                        onSaisie: _brouillon.majPaiement,
                      ),
                    const SizedBox(height: AppSpacing.p32),
                    const RecapMontants(),
                    const SizedBox(height: AppSpacing.p12),
                    Text(
                      'Paiement chiffré. Votre pièce est réservée pendant '
                      '15 minutes.',
                      textAlign: TextAlign.center,
                      style: ClosetTextStyles.meta.copyWith(
                        color: ClosetColors.taupe,
                      ),
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
                        total == null
                            ? 'Poursuivre — Paiement'
                            : 'Poursuivre — Paiement ${formatPrixFcfa(total)}',
                        style: ClosetTextStyles.bouton.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.blanc,
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

/// Bloc d'adresse, dans l'une des deux saisies de la maquette.
///
/// Par défaut la sélection de ville (`162:5536`), plus courte ; un lien bascule
/// vers la cascade Région → Département → Quartier (`162:3844`) pour les
/// adresses hors des deux villes tarifées.
class _BlocAdresse extends StatelessWidget {
  const _BlocAdresse({
    required this.brouillon,
    required this.onVille,
    required this.onRegion,
    required this.onDepartement,
    required this.onQuartier,
    required this.onMode,
  });

  final BrouillonCommande brouillon;
  final VoidCallback onVille;
  final VoidCallback onRegion;
  final VoidCallback onDepartement;
  final ValueChanged<String> onQuartier;
  final ValueChanged<ModeAdresse> onMode;

  @override
  Widget build(BuildContext context) {
    final enCascade = brouillon.mode == ModeAdresse.cascade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!enCascade)
          ChampSelecteur(
            label: 'Ville de livraison',
            placeholder: 'Choisir ma ville',
            valeur: brouillon.ville?.nom,
            sousTexte: brouillon.ville?.delaiAnnonce,
            onTap: onVille,
          )
        else ...[
          ChampSelecteur(
            label: 'Région',
            placeholder: 'Choisir ma région',
            valeur: brouillon.region?.nom,
            onTap: onRegion,
          ),
          const SizedBox(height: AppSpacing.p20),
          ChampSelecteur(
            label: 'Département',
            placeholder: brouillon.region == null
                ? "Choisissez d'abord une région"
                : 'Choisir mon département',
            valeur: brouillon.departement?.nom,
            actif: brouillon.region != null,
            onTap: onDepartement,
          ),
          const SizedBox(height: AppSpacing.p20),
          ChampCheckout(
            label: 'Quartier',
            hint: 'Newtown Collège, face pharmacie',
            onChanged: onQuartier,
          ),
        ],
        const SizedBox(height: AppSpacing.p12),
        Semantics(
          button: true,
          child: GestureDetector(
            onTap: () => onMode(
              enCascade ? ModeAdresse.ville : ModeAdresse.cascade,
            ),
            child: Text(
              enCascade
                  ? 'Revenir au choix par ville'
                  : 'Saisir une adresse détaillée',
              style: ClosetTextStyles.meta.copyWith(
                color: ClosetColors.fond400,
                decoration: TextDecoration.underline,
                decorationColor: ClosetColors.fond400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Ligne de moyen de paiement, dépliée en formulaire quand elle est retenue.
///
/// La maquette montre le mobile money demandant un numéro (`162:4647`) et la
/// carte demandant porteur, numéro, CVV et expiration (`162:5427`). Les deux
/// apparaissent sous la ligne choisie plutôt que sur un écran séparé, ce qui
/// évite une navigation que la maquette ne dessine pas.
class _LignePaiement extends StatelessWidget {
  const _LignePaiement({
    required this.moyen,
    required this.choisi,
    required this.onTap,
    required this.onSaisie,
  });

  final MoyenPaiement moyen;
  final bool choisi;
  final VoidCallback onTap;

  final void Function({
    String? numeroPaiement,
    String? porteurCarte,
    String? numeroCarte,
    String? cvv,
    String? expiration,
  }) onSaisie;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.p12),
      decoration: BoxDecoration(
        color: context.closetCarte,
        borderRadius: BorderRadius.circular(AppRadius.carte),
        border: Border.all(
          color: choisi ? ClosetColors.vert : ClosetColors.fond300,
          width: choisi ? AppStroke.moyen : AppStroke.fin,
        ),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            selected: choisi,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.carte),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.p12),
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
                    if (moyen.compteMasque.isNotEmpty) ...[
                      Text(
                        moyen.compteMasque,
                        style: ClosetTextStyles.meta.copyWith(
                          color: ClosetColors.taupe,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p8),
                    ],
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
          ),
          if (choisi && moyen.saisie != SaisieMoyen.aucune)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.p12,
                0,
                AppSpacing.p12,
                AppSpacing.p16,
              ),
              child: switch (moyen.saisie) {
                SaisieMoyen.telephone => ChampCheckout(
                    label: 'Numéro ${moyen.libelle}',
                    hint: '6 90 12 34 56',
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => onSaisie(numeroPaiement: v),
                  ),
                SaisieMoyen.carte => Column(
                    children: [
                      ChampCheckout(
                        label: 'Nom du porteur',
                        hint: 'AICHA NGONO',
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (v) => onSaisie(porteurCarte: v),
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      ChampCheckout(
                        label: 'Numéro de carte',
                        hint: '4864 0000 0000 0000',
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        onChanged: (v) => onSaisie(numeroCarte: v),
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ChampCheckout(
                              label: 'Expiration',
                              hint: 'MM/AA',
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                              onChanged: (v) => onSaisie(expiration: v),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.p16),
                          Expanded(
                            child: ChampCheckout(
                              label: 'CVV',
                              hint: '123',
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              onChanged: (v) => onSaisie(cvv: v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                SaisieMoyen.aucune => const SizedBox.shrink(),
              },
            ),
        ],
      ),
    );
  }
}
