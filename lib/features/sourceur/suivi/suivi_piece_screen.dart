import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_frise.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../sourceur_layout.dart';
import '../widgets/sourceur_header.dart';

/// Suivi d'une pièce confiée — transcription des maquettes `34:1710`
/// (acceptation) et `34:1578` (refus).
///
/// Les deux maquettes partagent la même frise : réception, analyse, décision.
/// Seules les deux dernières étapes divergent, d'où un seul écran piloté par
/// le statut de la pièce plutôt que deux copies.
class SuiviPieceScreen extends ConsumerWidget {
  const SuiviPieceScreen({super.key, required this.pieceId});

  final String pieceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piece = ref.watch(pieceSourceurProvider(pieceId));

    ref.listen(pieceSourceurProvider(pieceId), (precedent, suivant) {
      signaleTransitionAsync(
        ref: ref,
        context: context,
        precedent: precedent,
        suivant: suivant,
        titre: 'Suivi de pièce',
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Suivre ma pièce',
              onRetour: () => context.pop(),
            ),
            Expanded(
              child: piece.when(
                data: (p) => _Corps(piece: p),
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () =>
                      ref.invalidate(pieceSourceurProvider(pieceId)),
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
  const _Corps({required this.piece});

  final PieceDeposee piece;

  @override
  Widget build(BuildContext context) {
    final refusee = piece.statut == StatutPiece.refusee;
    final details = [
      if (piece.taille != null) 'Taille ${piece.taille}',
      if (piece.etat != null) libelleCondition(piece.etat),
      if (piece.methodeCollecte != null)
        libelleMethodeCollecte(piece.methodeCollecte),
      if (piece.prix > 0) '${piece.prix.round()} FCFA',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p20,
        AppSpacing.p20,
        AppSpacing.p32,
      ),
      children: [
        Text(
          piece.univers.toUpperCase(),
          style: ClosetTextStyles.actionPetite.copyWith(
            letterSpacing: 0.30,
            color: ClosetColors.fond400,
          ),
        ),
        const SizedBox(height: AppSpacing.p4),
        Text(
          piece.nom,
          style: ClosetTextStyles.libelleFort.copyWith(
            letterSpacing: -0.28,
            color: ClosetColors.vert,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        Text(
          details.isEmpty ? 'Informations reçues' : details.join(' · '),
          style: ClosetTextStyles.corps.copyWith(
            color: ClosetColors.neutre900,
          ),
        ),
        if (piece.raisonRefus != null && piece.raisonRefus!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.p8),
          Text(
            piece.raisonRefus!,
            style: ClosetTextStyles.corps.copyWith(
              color: ClosetColors.refusTexte,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.p32),
        Text(
          'Évolution et analyse de votre pièce'.toUpperCase(),
          style: ClosetTextStyles.corps.copyWith(
            letterSpacing: 0.96,
            color: ClosetColors.fond500,
          ),
        ),
        const SizedBox(height: AppSpacing.p24),
        ClosetFrise(etapes: _etapes(piece, refusee)),
        const SizedBox(height: AppSpacing.p32),
        Center(
          child: SizedBox(
            width: 312,
            height: 44,
            child: Material(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: () =>
                    allerOngletSourceur(context, OngletSourceur.espace),
                child: Center(
                  child: Text(
                    'Retour dans Mon Espace',
                    style: ClosetTextStyles.bouton.copyWith(
                      color: ClosetColors.blanc,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (refusee) ...[
          const SizedBox(height: AppSpacing.p16),
          Center(
            child: TextButton(
              onPressed: () =>
                  allerOngletSourceur(context, OngletSourceur.confier),
              child: Text(
                'Soumettre une nouvelle pièce',
                style: ClosetTextStyles.bouton.copyWith(
                  color: ClosetColors.vert,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Trois étapes communes, puis deux étapes qui dépendent de la décision.
  /// Aligné sur `SubmissionStatus` : submitted → in_review → accepted/refused
  /// → catalogued.
  static List<EtapeFrise> _etapes(PieceDeposee piece, bool refusee) {
    final statut = piece.statutApi;
    final retournee = piece.statut == StatutPiece.retournee;
    final analysee = statut == 'in_review' ||
        statut == 'accepted' ||
        statut == 'catalogued' ||
        statut == 'refused';
    final decidee = statut == 'accepted' ||
        statut == 'catalogued' ||
        statut == 'refused';
    final publiee = statut == 'catalogued' || piece.statut == StatutPiece.vendue;

    return [
      const EtapeFrise(
        titre: 'Reception de la pièce',
        detail: 'Votre pièce nous est parvenue',
        atteinte: true,
      ),
      EtapeFrise(
        titre: 'En cours d’analyse',
        detail: 'Nous vérifions l’état de votre pièce conformément aux '
            'normes de ClosET',
        atteinte: analysee,
      ),
      EtapeFrise(
        titre: 'Décision de ClosET',
        detail: 'Acceptation ou refus de la pièce conformément aux normes '
            'de ClosET',
        atteinte: decidee,
      ),
      if (refusee) ...[
        const EtapeFrise(
          titre: 'Article Refusé',
          detail: 'La pièce ne correspond pas aux normes actuelles de ClosET.',
          echec: true,
        ),
        EtapeFrise(
          titre: 'Retour de l’article',
          detail: retournee
              ? 'Votre pièce vous a été retournée.'
              : 'Vous recevrez votre pièce d’ici peu',
          atteinte: retournee,
        ),
      ] else ...[
        EtapeFrise(
          titre: 'Article Accepté',
          detail: 'La pièce correspond parfaitement aux normes actuelles '
              'de ClosET.',
          atteinte: decidee && !refusee,
        ),
        EtapeFrise(
          titre: 'Article Mis en Vente',
          detail: publiee
              ? 'Votre article a été mis en vente avec succès.'
              : 'Mise en vente à venir',
          atteinte: publiee,
        ),
      ],
    ];
  }
}
