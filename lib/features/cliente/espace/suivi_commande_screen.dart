import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_frise.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../data/models/commande.dart';
import '../../../data/repositories/commande_repository.dart';
import '../../sourceur/widgets/sourceur_header.dart';
import 'mes_commandes_screen.dart';

/// Voyage de la commande — maquette « Page suivie de pièce ».
class SuiviCommandeScreen extends ConsumerWidget {
  const SuiviCommandeScreen({
    super.key,
    required this.numero,
    this.depuisPaiement = false,
  });

  final String numero;
  final bool depuisPaiement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = ref.watch(commandeProvider(numero));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/espace/commandes');
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Suivre ma pièce',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ebGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.noir,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: commande.when(
                data: (c) => c == null
                    ? EtatEcran.vide(
                        titre: 'Commande introuvable',
                        message: 'Le suivi n’est plus disponible pour cette commande.',
                        action: () => context.pop(),
                        libelleAction: 'Retour',
                      )
                    : _Corps(commande: c),
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(commandeProvider(numero)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, AppSpacing.p16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    side: const BorderSide(
                      color: ClosetColors.noir,
                      width: AppStroke.fin,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => context.push('/espace/contact'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: ClosetColors.noir,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Laissez-nous un message',
                          style: ClosetTextStyles.bouton.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ClosetColors.noir,
                          ),
                        ),
                      ],
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
}

class _Corps extends StatelessWidget {
  const _Corps({required this.commande, required this.depuisPaiement});

  final Commande commande;
  final bool depuisPaiement;

  @override
  Widget build(BuildContext context) {
    final etapes = _etapes(commande, depuisPaiement);
    final iconeActive = etapes.where((e) => e.faite || e.courante).length.clamp(1, 4);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p8,
        AppSpacing.p20,
        AppSpacing.p24,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.carte),
            border: Border.all(color: ClosetColors.ligne, width: AppStroke.fin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMMANDE #${commande.numero}',
                style: ClosetTextStyles.libelleFort.copyWith(
                  letterSpacing: 0.2,
                  color: ClosetColors.noir,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                depuisPaiement
                    ? 'Temps d\'estimation: ${formatDateCommande(commande.estimation ?? commande.dateDepot)}'
                    : ligneDateCommande(commande),
                style: ClosetTextStyles.corps.copyWith(
                  color: ClosetColors.taupe,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.p24),
        _BarreIcones(actives: iconeActive),
        const SizedBox(height: AppSpacing.p24),
        Text(
          'VOYAGE DE VOTRE PIÈCE',
          style: ClosetTextStyles.meta.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: ClosetColors.fond400,
          ),
        ),
        const SizedBox(height: AppSpacing.p20),
        _FriseVoyage(etapes: etapes),
      ],
    );
  }

  static List<_EtapeVoyage> _etapes(Commande c, bool depuisPaiement) {
    final statut = depuisPaiement ? StatutCommande.preparation : c.statut;
    final date = formatDateCommande(c.dateDepot);
    final moyen = depuisPaiement ? 'Visa Card' : 'MTN MoMo';

    return [
      _EtapeVoyage(
        titre: 'Sélection confirmée',
        detail: date,
        faite: true,
        coche: true,
      ),
      _EtapeVoyage(
        titre: 'Paiement confirmé',
        detail: '$date, $moyen',
        faite: true,
      ),
      EtapeFrise(
        titre: 'Préparée avec soin',
        detail: enRoute
            ? 'Votre pièce a reçu son packaging Clos ET'
            : 'Votre pièce reçoit son packaging Clos ET',
        atteinte: enRoute,
        enCours: !enRoute,
      ),
      _EtapeVoyage(
        titre: 'En route pour livraison',
        detail: c.estimation == null
            ? 'Livraison en cours de planification'
            : 'Livraison estimée : ${formatDateCommande(c.estimation!)}',
        atteinte: livree,
        enCours: enRoute && !livree,
      ),
      _EtapeVoyage(
        titre: 'Dans votre dressing',
        detail:
            livree ? 'Votre pièce vous a été remise' : 'Dès la livraison faite',
        atteinte: livree,
      ),
    ];
  }
}

class _EtapeVoyage {
  const _EtapeVoyage({
    required this.titre,
    required this.detail,
    this.faite = false,
    this.courante = false,
    this.coche = false,
  });

  final String titre;
  final String detail;
  final bool faite;
  final bool courante;
  final bool coche;
}

class _BarreIcones extends StatelessWidget {
  const _BarreIcones({required this.actives});

  final int actives;

  static const _icones = [
    Icons.inventory_2_outlined,
    Icons.redeem_outlined,
    Icons.local_shipping_outlined,
    Icons.assignment_turned_in_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _icones.length; i++) ...[
          _PuceIcone(icone: _icones[i], active: i < actives),
          if (i < _icones.length - 1)
            Expanded(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: _Tirets(couleur: ClosetColors.fond300),
              ),
            ),
        ],
      ],
    );
  }
}

class _PuceIcone extends StatelessWidget {
  const _PuceIcone({required this.icone, required this.active});

  final IconData icone;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? ClosetColors.vert : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? ClosetColors.vert : ClosetColors.fond300,
          width: AppStroke.fin,
        ),
      ),
      child: Icon(
        icone,
        size: 20,
        color: active ? Colors.white : ClosetColors.fond400,
      ),
    );
  }
}

class _Tirets extends StatelessWidget {
  const _Tirets({required this.couleur});

  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 4.0;
        const gap = 3.0;
        final n = (c.maxWidth / (dash + gap)).floor().clamp(1, 40);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < n; i++)
              Container(width: dash, height: 1.2, color: couleur),
          ],
        );
      },
    );
  }
}

class _FriseVoyage extends StatelessWidget {
  const _FriseVoyage({required this.etapes});

  final List<_EtapeVoyage> etapes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < etapes.length; i++)
          _LigneVoyage(
            etape: etapes[i],
            derniere: i == etapes.length - 1,
          ),
      ],
    );
  }
}

class _LigneVoyage extends StatelessWidget {
  const _LigneVoyage({required this.etape, required this.derniere});

  final _EtapeVoyage etape;
  final bool derniere;

  Color get _couleur {
    if (etape.courante) return ClosetColors.fond400;
    if (etape.faite) return ClosetColors.vert;
    return ClosetColors.fond300;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: etape.faite || etape.courante
                      ? _couleur
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _couleur, width: AppStroke.moyen),
                ),
                child: etape.coche
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              if (!derniere)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: ClosetColors.fond300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: derniere ? 0 : AppSpacing.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etape.titre,
                    style: ClosetTextStyles.libelle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.noir,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    etape.detail,
                    style: ClosetTextStyles.meta.copyWith(
                      color: ClosetColors.taupe,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
