import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_frise.dart';
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
    final commande = ref.watch(commandeProvider(numero));

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Suivre ma pièce',
              surtitre: 'ma commande',
              onRetour: () => context.pop(),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.chat_bubble_outline_rounded,
                  label: 'Laissez-nous un message',
                  onTap: () => context.push('/espace/contact'),
                ),
              ],
            ),
            Expanded(
              child: commande.when(
                data: (c) => c == null
                    ? const Center(child: Text('Commande introuvable'))
                    : _Corps(commande: c),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: ClosetColors.dore),
                ),
                error: (e, _) => const Center(
                  child: Text('Erreur de chargement'),
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
          ligneDateCommande(commande),
          style: ClosetTextStyles.corps.copyWith(
            color: ClosetColors.neutre900,
          ),
        ),
        const SizedBox(height: AppSpacing.p32),
        Text(
          'Voyage de votre pièce'.toUpperCase(),
          style: ClosetTextStyles.corps.copyWith(
            letterSpacing: 0.96,
            color: ClosetColors.fond500,
          ),
        ),
        const SizedBox(height: AppSpacing.p24),
        ClosetFrise(etapes: _etapes(commande)),
      ],
    );
  }

  /// Les cinq étapes du voyage, déduites du statut de la commande.
  static List<EtapeFrise> _etapes(Commande c) {
    final enRoute = c.statut == StatutCommande.enRoute ||
        c.statut == StatutCommande.livree;
    final livree = c.statut == StatutCommande.livree;

    return [
      EtapeFrise(
        titre: 'Sélection confirmée',
        detail: formatDateCommande(c.dateDepot),
        atteinte: true,
      ),
      EtapeFrise(
        titre: 'Paiement confirmé',
        detail: formatDateCommande(c.dateDepot),
        atteinte: true,
      ),
      const EtapeFrise(
        titre: 'Préparée avec soin',
        detail: 'Votre pièce reçoit son packaging Clos ET',
        atteinte: true,
      ),
      EtapeFrise(
        titre: 'En route pour livraison',
        detail: c.estimation == null
            ? 'Livraison en cours de planification'
            : 'Livraison estimée : ${formatDateCommande(c.estimation!)}',
        atteinte: enRoute,
      ),
      EtapeFrise(
        titre: 'Dans votre dressing',
        detail: livree ? 'Votre pièce vous a été remise' : 'Pas encore',
        atteinte: livree,
      ),
    ];
  }
}
