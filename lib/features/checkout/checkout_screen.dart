import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../cliente/selection/selection_screen.dart';
import '../sourceur/retrait/methode_retrait_sheet.dart';
import '../sourceur/widgets/sourceur_header.dart';
import 'paiement_flow_screen.dart';

const _villesLivraison = [
  (id: 'yaounde', nom: 'Yaoundé', detail: 'Livraison à domicile 24h-48h', region: 'Centre'),
  (id: 'douala', nom: 'Douala', detail: 'Livraison à domicile 24h-48h', region: 'Littoral'),
  (id: 'autre', nom: 'Autre', detail: 'A determiner', region: 'Autre'),
];

/// Ordre de la maquette « Ma sélection E1 ».
const _regionsCameroun = [
  'Adamaoua',
  'Centre',
  'Extrême-Nord',
  'Est',
  'Littoral',
  'Nord Ouest',
  'Ouest',
  'Sud',
  'Sud-Ouest',
  'Nord',
];

const _departementsParRegion = {
  'Adamaoua': ['Djérem', 'Faro-et-Déo', 'Mayo-Banyo', 'Mbéré', 'Vina'],
  'Centre': [
    'Mbalmayo',
    'Haute-Sanaga',
    'Lékié',
    'Mbam-et-Inoubou',
    'Mbam-et-Kim',
    'Méfou-et-Afamba',
    'Méfou-et-Akono',
    'Mfoundi',
    'Nyong-et-Kéllé',
    'Nyong-et-Mfoumou',
    "Nyong-et-So'o",
  ],
  'Est': ['Boumba-et-Ngoko', 'Haut-Nyong', 'Kadey', 'Lom-et-Djérem'],
  'Extrême-Nord': [
    'Diamaré',
    'Logone-et-Chari',
    'Mayo-Danay',
    'Mayo-Kani',
    'Mayo-Sava',
    'Mayo-Tsanaga',
  ],
  'Littoral': ['Moungo', 'Nkam', 'Sanaga-Maritime', 'Wouri'],
  'Nord': ['Bénoué', 'Faro', 'Mayo-Louti', 'Mayo-Rey'],
  'Nord Ouest': [
    'Boyo',
    'Bui',
    'Donga-Mantung',
    'Menchum',
    'Mezam',
    'Momo',
    'Ngo-Ketunjia',
  ],
  'Ouest': [
    'Bamboutos',
    'Haut-Nkam',
    'Hauts-Plateaux',
    'Koung-Khi',
    'Menoua',
    'Mifi',
    'Ndé',
    'Noun',
  ],
  'Sud': ['Dja-et-Lobo', 'Mvila', 'Océan', 'Vallée-du-Ntem'],
  'Sud-Ouest': [
    'Fako',
    'Koupé-Manengouba',
    'Lebialem',
    'Manyu',
    'Meme',
    'Ndian',
  ],
};

/// Finalisation de la sélection — étape 1/3 (livraison).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _quartier = TextEditingController();
  String? _moyen;
  String? _ville;
  String? _region;
  String? _departement;
  bool _ficheLivraison = false;
  bool _recapLivraison = false;
  bool _totaux = false;
  bool _totauxPrets = false;
  bool _livraisonOuverte = true;
  bool _coordonneesValidees = false;
  Timer? _timerTotaux;

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
    _timerTotaux?.cancel();
    _nom.dispose();
    _telephone.dispose();
    _quartier.dispose();
    super.dispose();
  }

  MoyenRetrait? get _moyenChoisi {
    if (_moyen == null) return null;
    for (final m in moyensRetrait) {
      if (m.id == _moyen) return m;
    }
    return null;
  }

  String? get _libelleVille {
    if (_ville == null) return null;
    for (final v in _villesLivraison) {
      if (v.id == _ville) return v.nom;
    }
    return null;
  }

  List<String> get _departements {
    if (_region == null) return const [];
    return _departementsParRegion[_region] ?? const [];
  }

  bool _validerIdentite({bool silencieux = false}) {
    if (_formKey.currentState?.validate() ?? false) return true;
    if (!silencieux) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complétez nom et téléphone.')),
      );
    }
    return false;
  }

  bool _validerLivraison({bool silencieux = false}) {
    if (!_validerIdentite(silencieux: silencieux)) return false;
    if (_region == null ||
        _departement == null ||
        _quartier.text.trim().isEmpty) {
      if (!silencieux) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Indiquez région, département et quartier de livraison.',
            ),
          ),
        );
      }
      return false;
    }
    setState(() => _coordonneesValidees = true);
    return true;
  }

  String get _resumeAdresse {
    final quartier = _quartier.text.trim();
    final lieu = [
      ?_departement,
      ?_region,
    ].join('-');
    if (lieu.isEmpty) return 'Veuillez entrez vos informations';
    if (quartier.isEmpty) return lieu;
    return '$lieu, $quartier';
  }

  String get _libellePaiement {
    if (_moyen == 'visa') return 'Visa Card';
    return _moyenChoisi?.libelle ?? 'Veuillez choisir la methode paiement';
  }

  String _formatMontant(double valeur) {
    final n = valeur.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      final depuisLaFin = n.length - i;
      if (i != 0 && depuisLaFin % 3 == 0) buf.write('.');
      buf.write(n[i]);
    }
    return '$buf FCFA';
  }

  void _ouvrirEcranAdresse() {
    if (_nom.text.trim().isEmpty) _nom.text = 'Aïcha N.';
    if (_telephone.text.trim().isEmpty) {
      _telephone.text = '+237 6 90 12 34 56';
    }
    _region = 'Centre';
    _departement = 'Mbalmayo';
    _quartier.text = 'Newton- Collège Saint Coeur de Marie';
    setState(() {
      _ficheLivraison = true;
      _recapLivraison = true;
      _totaux = false;
      _totauxPrets = false;
      _livraisonOuverte = true;
      _coordonneesValidees = false;
    });
  }

  void _ouvrirEcranTotaux() {
    _timerTotaux?.cancel();
    if (_nom.text.trim().isEmpty) _nom.text = 'Aïcha N.';
    if (_telephone.text.trim().isEmpty) {
      _telephone.text = '+237 6 90 12 34 56';
    }
    _region ??= 'Centre';
    _departement ??= 'Mbalmayo';
    if (_quartier.text.trim().isEmpty) {
      _quartier.text = 'Newton- Collège Saint Coeur de Marie';
    }
    _moyen = 'visa';
    setState(() {
      _ficheLivraison = true;
      _recapLivraison = true;
      _totaux = true;
      _totauxPrets = false;
      _livraisonOuverte = false;
      _coordonneesValidees = true;
    });
    _timerTotaux = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _totauxPrets = true);
    });
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

    final sous = ref.read(cartTotalProvider);
    final total = sous + fraisLivraison;
    context.push(
      '/checkout/paiement',
      extra: PaiementFlowArgs(
        nom: _nom.text.trim(),
        telephone: _telephone.text.trim(),
        moyen: _libellePaiement,
        montant: total > fraisLivraison ? total : 42000,
      ),
    );
  }

  void _retour() {
    if (_totaux) {
      _timerTotaux?.cancel();
      setState(() {
        _totaux = false;
        _totauxPrets = false;
        _livraisonOuverte = true;
        _coordonneesValidees = false;
      });
      return;
    }
    if (_recapLivraison || _ficheLivraison) {
      setState(() {
        _recapLivraison = false;
        _ficheLivraison = false;
      });
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/selection');
    }
  }

  void _appliquerVille(String choisie) {
    final ville = _villesLivraison.firstWhere((v) => v.id == choisie);
    setState(() {
      _ville = choisie;
      _region = ville.region == 'Autre' ? null : ville.region;
      final deps = _departements;
      if (!deps.contains(_departement)) _departement = null;
      _coordonneesValidees = false;
    });
  }

  Future<void> _choisirVille() async {
    final choisie = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _DialogueSelection(
        titre: 'Choisir la ville de livraison',
        options: [
          for (final v in _villesLivraison)
            (id: v.id, nom: v.nom, detail: v.detail),
        ],
        actuelle: _ville ?? 'yaounde',
      ),
    );
    if (choisie != null && mounted) {
      _appliquerVille(choisie);
    }
  }

  Future<void> _choisirPaiement() async {
    final choisi = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _DialogueSelection(
        titre: 'Choisir la méthode de paiement',
        options: [
          for (final m in moyensRetrait)
            (
              id: m.id,
              nom: m.libelle,
              detail: m.id == 'visa'
                  ? 'Paiement par carte'
                  : 'Paiement mobile',
            ),
        ],
        actuelle: _moyen,
      ),
    );
    if (choisi != null && mounted) {
      setState(() {
        _moyen = choisi;
        _coordonneesValidees = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            _EnTeteCheckout(onRetour: _retour),
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
                    ..._corpsLivraison(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, AppSpacing.p16),
              child: _BoutonPoursuivre(
                pret: _totaux && _totauxPrets,
                charge: _totaux && !_totauxPrets,
                onTap: _poursuivre,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corpsLivraison() {
    final sous = ref.watch(cartTotalProvider);
    final total = sous + fraisLivraison;
    final montant = total > fraisLivraison ? total : 42000;
    return [
      _ChampCheckout(
        label: 'Nom complet',
        hint: 'Aïcha N.',
        controller: _nom,
        textInputAction: TextInputAction.next,
        validator: (v) => (v == null || v.trim().length < 2)
            ? 'Indiquez votre nom complet.'
            : null,
      ),
      const SizedBox(height: AppSpacing.p20),
      _ChampCheckout(
        label: 'Téléphone (Whatsapp)',
        hint: '+237 6 90 12 34 56',
        controller: _telephone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        validator: _validerTelephone,
      ),
      const SizedBox(height: AppSpacing.p8),
      Text(
        'Nous vous écrirons sur WhatsApp pour suivre votre pièce.',
        style: ClosetTextStyles.meta.copyWith(
          color: ClosetColors.fond400,
        ),
      ),
      const SizedBox(height: AppSpacing.p24),
      if (_totaux)
        _LigneMenu(
          icone: Icons.location_on_outlined,
          titre: 'Détails de livraison',
          sousTitre: _resumeAdresse,
          onTap: () {
            _timerTotaux?.cancel();
            setState(() {
              _totaux = false;
              _totauxPrets = false;
              _livraisonOuverte = true;
              _coordonneesValidees = false;
            });
          },
        )
      else if (_ficheLivraison)
        _FicheLivraison(
          ouvert: !_recapLivraison || _livraisonOuverte,
          resume: _recapLivraison
              ? _resumeAdresse
              : 'Veuillez entrez vos informations',
          onEntete: _recapLivraison
              ? () => setState(() {
                    _livraisonOuverte = !_livraisonOuverte;
                    _coordonneesValidees = !_livraisonOuverte;
                  })
              : null,
          region: _region,
          departement: _departement,
          departements: _departements,
          quartier: _quartier,
          onRegion: (region) => setState(() {
            _region = region;
            if (!_departements.contains(_departement)) {
              _departement = null;
            }
            _coordonneesValidees = false;
          }),
          onDepartement: (departement) => setState(() {
            _departement = departement;
            _coordonneesValidees = false;
          }),
        )
      else
        _LigneMenu(
          icone: Icons.location_on_outlined,
          titre: 'Détails de livraison',
          sousTitre: _libelleVille ?? 'Veuillez entrez vos informations',
          onTap: _choisirVille,
        ),
      const SizedBox(height: AppSpacing.p12),
      _LigneMenu(
        icone: Icons.account_balance_wallet_outlined,
        titre: 'Méthode de paiement',
        sousTitre: _libellePaiement,
        onTap: _choisirPaiement,
      ),
      const SizedBox(height: AppSpacing.p24),
      Row(
        children: [
          Expanded(
            child: Text(
              'VALIDER LES INFORMATIONS',
              style: ClosetTextStyles.meta.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: ClosetColors.noir,
              ),
            ),
          ),
          Switch(
            value: _coordonneesValidees,
            activeThumbColor: Colors.white,
            activeTrackColor: ClosetColors.vert,
            onChanged: (v) {
              if (v) {
                if (!_validerLivraison()) return;
                setState(() => _livraisonOuverte = false);
              } else {
                setState(() {
                  _coordonneesValidees = false;
                  if (_recapLivraison) _livraisonOuverte = true;
                });
              }
            },
          ),
        ],
      ),
      if (_totaux) ...[
        const SizedBox(height: AppSpacing.p32),
        if (!_totauxPrets)
          const Center(child: _SpinnerDore())
        else
          _CarteTotal(montant: _formatMontant(montant.toDouble())),
      ],
    ];
  }

  static String? _validerTelephone(String? v) {
    final chiffres = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (chiffres.isEmpty) return 'Indiquez un numéro WhatsApp.';
    if (chiffres.length < 9) return 'Ce numéro semble incomplet.';
    return null;
  }
}

class _ChampCheckout extends StatelessWidget {
  const _ChampCheckout({
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
            color: ClosetColors.noir,
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
              vertical: 14,
            ),
            border: _bordure(),
            enabledBorder: _bordure(),
            focusedBorder: _bordure(ClosetColors.fond400),
            errorBorder: _bordure(ClosetColors.erreurCouture),
            focusedErrorBorder: _bordure(ClosetColors.erreurCouture),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _bordure([Color couleur = ClosetColors.fond300]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        borderSide: BorderSide(color: couleur, width: AppStroke.fin),
      );
}

class _EnTeteCheckout extends StatelessWidget {
  const _EnTeteCheckout({required this.onRetour});

  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p16,
        AppSpacing.p8,
        AppSpacing.p16,
        AppSpacing.p12,
      ),
      child: Row(
        children: [
          SourceurBoutonRond(
            icone: Icons.arrow_back_ios_new,
            label: 'Retour',
            onTap: onRetour,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Ma sélection',
                  style: ClosetTextStyles.titreSection.copyWith(fontSize: 20),
                ),
                Text(
                  'ÉTAPE 1/3',
                  style: ClosetTextStyles.meta.copyWith(
                    letterSpacing: 1.2,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
          ),
          SourceurBoutonRond(
            icone: Icons.shopping_basket_outlined,
            label: 'Ma sélection',
            onTap: () => context.go('/selection'),
          ),
          const SizedBox(width: AppSpacing.p8),
          SourceurBoutonRond(
            icone: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () => context.go('/espace/alertes'),
          ),
        ],
      ),
    );
  }
}

class _FriseEtapes extends StatelessWidget {
  const _FriseEtapes({required this.etapeCourante});

  final int etapeCourante;

  static const _etapes = ['LIVRAISON', 'PAIEMENT', 'CONFIRMATION'];

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
                height: AppStroke.fin,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: ClosetColors.ligne,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: atteinte ? ClosetColors.vert : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: atteinte ? ClosetColors.vert : ClosetColors.noir,
              width: AppStroke.fin,
            ),
          ),
          child: Text(
            '$numero',
            style: ClosetTextStyles.micro.copyWith(
              fontWeight: FontWeight.w700,
              color: atteinte ? Colors.white : ClosetColors.noir,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: ClosetTextStyles.microLegende.copyWith(
            letterSpacing: 0.4,
            fontWeight: atteinte ? FontWeight.w700 : FontWeight.w400,
            color: atteinte ? ClosetColors.noir : ClosetColors.taupe,
          ),
        ),
      ],
    );
  }
}

class _LigneMenu extends StatelessWidget {
  const _LigneMenu({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ClosetColors.neutre100,
      borderRadius: BorderRadius.circular(AppRadius.carte),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.carte),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p12,
            vertical: AppSpacing.p12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ClosetColors.neutre200,
                  borderRadius: BorderRadius.circular(AppRadius.carte),
                ),
                child: Icon(icone, size: 18, color: ClosetColors.noir),
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: ClosetTextStyles.libelle),
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ClosetTextStyles.meta.copyWith(
                        color: ClosetColors.taupe,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: ClosetColors.noir,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FicheLivraison extends StatelessWidget {
  const _FicheLivraison({
    required this.ouvert,
    required this.resume,
    required this.region,
    required this.departement,
    required this.departements,
    required this.quartier,
    required this.onRegion,
    required this.onDepartement,
    this.onEntete,
  });

  final bool ouvert;
  final String resume;
  final String? region;
  final String? departement;
  final List<String> departements;
  final TextEditingController quartier;
  final VoidCallback? onEntete;
  final ValueChanged<String> onRegion;
  final ValueChanged<String> onDepartement;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ClosetColors.neutre100,
      borderRadius: BorderRadius.circular(AppRadius.carte),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onEntete,
            borderRadius: BorderRadius.circular(AppRadius.carte),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p12,
                vertical: AppSpacing.p12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ClosetColors.neutre200,
                      borderRadius: BorderRadius.circular(AppRadius.carte),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: ClosetColors.noir,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails de livraison',
                          style: ClosetTextStyles.libelle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ouvert
                              ? 'Veuillez entrez vos informations'
                              : resume,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ClosetTextStyles.meta.copyWith(
                            color: ClosetColors.taupe,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    ouvert ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    size: 22,
                    color: ClosetColors.noir,
                  ),
                ],
              ),
            ),
          ),
          if (ouvert)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.p12,
                0,
                AppSpacing.p12,
                AppSpacing.p16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MenuSousChamp(
                          label: 'Région',
                          hint: '',
                          value: region,
                          options: _regionsCameroun,
                          onSelected: onRegion,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p12),
                      Expanded(
                        child: _MenuSousChamp(
                          label: 'Departement',
                          hint: '',
                          value: departement,
                          options: departements,
                          onSelected: onDepartement,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p16),
                  _ChampCheckout(
                    label: 'Quartier',
                    hint: '',
                    controller: quartier,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  Text(
                    'Veuillez écrire le nom de votre quartier',
                    style: ClosetTextStyles.meta.copyWith(
                      color: ClosetColors.fond400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuSousChamp extends StatefulWidget {
  const _MenuSousChamp({
    required this.label,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.value,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  State<_MenuSousChamp> createState() => _MenuSousChampState();
}

class _MenuSousChampState extends State<_MenuSousChamp> {
  final _lien = LayerLink();
  final _portail = OverlayPortalController();
  double _largeur = 160;

  void _basculer() {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) _largeur = box.size.width;
    _portail.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final vide = widget.value == null || widget.value!.isEmpty;
    return CompositedTransformTarget(
      link: _lien,
      child: OverlayPortal(
        controller: _portail,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _portail.hide,
                ),
              ),
              CompositedTransformFollower(
                link: _lien,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: Material(
                  color: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(AppRadius.carte),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 280,
                      minWidth: _largeur,
                      maxWidth: _largeur,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: widget.options.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: AppStroke.fin,
                        color: ClosetColors.ligne,
                      ),
                      itemBuilder: (context, i) {
                        final option = widget.options[i];
                        return InkWell(
                          onTap: () {
                            widget.onSelected(option);
                            _portail.hide();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.p12,
                              vertical: 12,
                            ),
                            child: Text(
                              option,
                              style: ClosetTextStyles.saisie.copyWith(
                                color: ClosetColors.noir,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: ClosetTextStyles.labelChamp.copyWith(
                fontWeight: FontWeight.w500,
                color: ClosetColors.noir,
              ),
            ),
            const SizedBox(height: AppSpacing.p8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.carte),
              child: InkWell(
                onTap: widget.options.isEmpty ? null : _basculer,
                borderRadius: BorderRadius.circular(AppRadius.carte),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.carte),
                    border: Border.all(
                      color: ClosetColors.fond300,
                      width: AppStroke.fin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          vide ? widget.hint : widget.value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ClosetTextStyles.saisie.copyWith(
                            color: vide
                                ? ClosetColors.placeholderGris
                                : ClosetColors.noir,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: ClosetColors.taupe,
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
}

class _BoutonPoursuivre extends StatelessWidget {
  const _BoutonPoursuivre({
    required this.pret,
    required this.charge,
    required this.onTap,
  });

  final bool pret;
  final bool charge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Material(
        color: pret ? ClosetColors.vert : ClosetColors.beige,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          side: pret
              ? BorderSide.none
              : const BorderSide(
                  color: ClosetColors.fond300,
                  width: AppStroke.moyen,
                ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          onTap: charge ? null : onTap,
          child: Center(
            child: Text(
              'Poursuivre -Paiement',
              style: ClosetTextStyles.bouton.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: pret ? ClosetColors.texteSurVert : ClosetColors.fond400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarteTotal extends StatelessWidget {
  const _CarteTotal({required this.montant});

  final String montant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sous-Total + Livraison',
            style: ClosetTextStyles.citation.copyWith(
              fontStyle: FontStyle.italic,
              color: ClosetColors.doreClair,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'TOTAL À RÉGLER',
                  style: ClosetTextStyles.libelle.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: ClosetColors.texteSurVert,
                  ),
                ),
              ),
              Text(
                montant,
                style: ClosetTextStyles.prixGrand.copyWith(
                  fontStyle: FontStyle.italic,
                  color: ClosetColors.texteSurVert,
                  fontSize: 26,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Paiement différé. Votre pièce est réservée pendant 15 minutes.',
            style: ClosetTextStyles.meta.copyWith(
              color: ClosetColors.doreClair,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinnerDore extends StatefulWidget {
  const _SpinnerDore();

  @override
  State<_SpinnerDore> createState() => _SpinnerDoreState();
}

class _SpinnerDoreState extends State<_SpinnerDore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _FiletDorePainter(progres: _ctrl.value),
          );
        },
      ),
    );
  }
}

class _FiletDorePainter extends CustomPainter {
  const _FiletDorePainter({required this.progres});

  final double progres;

  @override
  void paint(Canvas canvas, Size size) {
    const points = 10;
    final centre = Offset(size.width / 2, size.height / 2);
    final rayon = size.shortestSide / 2 - 4;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < points; i++) {
      final t = (((i / points) - progres) % 1.0 + 1.0) % 1.0;
      final angle = (i / points) * 2 * math.pi - math.pi / 2;
      paint.color = ClosetColors.fond300.withValues(alpha: 0.2 + 0.8 * t);
      canvas.drawCircle(
        Offset(
          centre.dx + rayon * math.cos(angle),
          centre.dy + rayon * math.sin(angle),
        ),
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FiletDorePainter oldDelegate) =>
      oldDelegate.progres != progres;
}

class _DialogueSelection extends StatefulWidget {
  const _DialogueSelection({
    required this.titre,
    required this.options,
    this.actuelle,
  });

  final String titre;
  final List<({String id, String nom, String detail})> options;
  final String? actuelle;

  @override
  State<_DialogueSelection> createState() => _DialogueSelectionState();
}

class _DialogueSelectionState extends State<_DialogueSelection> {
  late String? _choisie = widget.actuelle ?? widget.options.first.id;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.p12),
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.close, size: 18, color: ClosetColors.noir),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.bloc),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.titre, style: ClosetTextStyles.libelleFort),
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  for (var i = 0; i < widget.options.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: AppStroke.fin,
                        color: ClosetColors.ligne,
                      ),
                    InkWell(
                      onTap: () {
                        setState(() => _choisie = widget.options[i].id);
                        Navigator.pop(context, widget.options[i].id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.options[i].nom,
                                    style: ClosetTextStyles.libelle,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.options[i].detail,
                                    style: ClosetTextStyles.meta.copyWith(
                                      color: ClosetColors.taupe,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _choisie == widget.options[i].id
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: ClosetColors.vert,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
