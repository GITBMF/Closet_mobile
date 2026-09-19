import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/closet_frise.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../data/models/commande.dart';
import '../../../data/repositories/commande_repository.dart';
import '../../sourceur/widgets/sourceur_header.dart';
import 'mes_commandes_screen.dart';

/// Voyage de la commande — transcription de la maquette `162:5657`.
///
/// Malgré son nom Figma « Page suivie de pièce », cet écran suit une
/// **commande cliente** : sélection, paiement, préparation, livraison.
class SuiviCommandeScreen extends ConsumerWidget {
  const SuiviCommandeScreen({super.key, required this.numero});

  final String numero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final commande = ref.watch(commandeProvider(numero));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: l10n.suiviMaPieceTitre,
              surtitre: l10n.maCommandeSurtitre,
              onRetour: () => context.pop(),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.chat_bubble_outline_rounded,
                  label: l10n.laissezNousMessage,
                  onTap: () => context.push('/espace/contact'),
                ),
              ],
            ),
            Expanded(
              child: commande.when(
                data: (c) => c == null
                    ? EtatEcran.vide(
                        titre: l10n.commandeIntrouvableTitre,
                        message: l10n.suiviIndisponible,
                        action: () => context.pop(),
                        libelleAction: l10n.retour,
                      )
                    : _Corps(commande: c),
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(commandeProvider(numero)),
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
  const _Corps({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p20,
        AppSpacing.p20,
        AppSpacing.p32,
      ),
      children: [
        Text(
          'COMMANDE #${commande.numero}',
          style: ClosetTextStyles.libelleFort.copyWith(
            letterSpacing: -0.28,
            color: ClosetColors.vert,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        Text(
          ligneDateCommande(commande, l10n),
          style: ClosetTextStyles.corps.copyWith(
            color: ClosetColors.neutre900,
          ),
        ),
        const SizedBox(height: AppSpacing.p32),
        Text(
          l10n.voyagePiece.toUpperCase(),
          style: ClosetTextStyles.corps.copyWith(
            letterSpacing: 0.96,
            color: ClosetColors.fond500,
          ),
        ),
        const SizedBox(height: AppSpacing.p24),
        ClosetFrise(etapes: _etapes(commande, l10n)),
      ],
    );
  }

  /// Les cinq étapes du voyage, déduites du statut de la commande.
  static List<EtapeFrise> _etapes(Commande c, ClosetL10n l10n) {
    final enRoute = c.statut == StatutCommande.enRoute ||
        c.statut == StatutCommande.livree;
    final livree = c.statut == StatutCommande.livree;

    return [
      EtapeFrise(
        titre: l10n.etapeSelectionConfirmee,
        detail: formatDateCommande(c.dateDepot),
        atteinte: true,
      ),
      EtapeFrise(
        titre: l10n.etapePaiementConfirme,
        detail: formatDateCommande(c.dateDepot),
        atteinte: true,
      ),
      EtapeFrise(
        titre: l10n.etapePrepareeAvecSoin,
        detail: enRoute ? l10n.etapePrepareeAFait : l10n.etapePrepareeEnCours,
        atteinte: enRoute,
        enCours: !enRoute,
      ),
      EtapeFrise(
        titre: l10n.etapeEnRouteTitre,
        detail: c.estimation == null
            ? l10n.etapeLivraisonPlanification
            : l10n.etapeLivraisonEstimee(formatDateCommande(c.estimation!)),
        atteinte: livree,
        enCours: enRoute && !livree,
      ),
      EtapeFrise(
        titre: l10n.etapeDressingTitre,
        detail: livree ? l10n.etapeDressingRemise : l10n.etapeDressingAVenir,
        atteinte: livree,
      ),
    ];
  }
}
