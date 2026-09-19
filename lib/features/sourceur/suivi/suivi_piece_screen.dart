import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
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
    final l10n = ClosetL10n.of(context);
    final piece = ref.watch(pieceSourceurProvider(pieceId));

    ref.listen(pieceSourceurProvider(pieceId), (precedent, suivant) {
      signaleTransitionAsync(
        ref: ref,
        context: context,
        precedent: precedent,
        suivant: suivant,
        titre: l10n.suiviPieceTitre,
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: l10n.suiviMaPieceTitre,
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
    final l10n = ClosetL10n.of(context);
    final refusee = piece.statut == StatutPiece.refusee;
    final details = [
      if (piece.taille != null) l10n.suiviTailleValeur(piece.taille!),
      if (piece.etat != null) libelleCondition(piece.etat, l10n),
      if (piece.methodeCollecte != null)
        libelleMethodeCollecte(piece.methodeCollecte, l10n),
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
          details.isEmpty ? l10n.suiviInformationsRecues : details.join(' · '),
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
          l10n.suiviEvolutionAnalyse.toUpperCase(),
          style: ClosetTextStyles.corps.copyWith(
            letterSpacing: 0.96,
            color: ClosetColors.fond500,
          ),
        ),
        const SizedBox(height: AppSpacing.p24),
        ClosetFrise(etapes: _etapes(piece, refusee, l10n)),
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
                    l10n.suiviRetourEspace,
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
                l10n.suiviSoumettreNouvelle,
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
  static List<EtapeFrise> _etapes(PieceDeposee piece, bool refusee, ClosetL10n l10n) {
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
      EtapeFrise(
        titre: l10n.suiviEtapeReceptionTitre,
        detail: l10n.suiviEtapeReceptionDetail,
        atteinte: true,
      ),
      EtapeFrise(
        titre: l10n.suiviEtapeAnalyseTitre,
        detail: l10n.suiviEtapeAnalyseDetail,
        atteinte: analysee,
      ),
      EtapeFrise(
        titre: l10n.suiviEtapeDecisionTitre,
        detail: l10n.suiviEtapeDecisionDetail,
        atteinte: decidee,
      ),
      if (refusee) ...[
        EtapeFrise(
          titre: l10n.suiviEtapeRefuseTitre,
          detail: l10n.suiviEtapeRefuseDetail,
          echec: true,
        ),
        EtapeFrise(
          titre: l10n.suiviEtapeRetourTitre,
          detail: retournee
              ? l10n.suiviEtapeRetourneDetail
              : l10n.suiviEtapeRetourAVenirDetail,
          atteinte: retournee,
        ),
      ] else ...[
        EtapeFrise(
          titre: l10n.suiviEtapeAccepteTitre,
          detail: l10n.suiviEtapeAccepteDetail,
          atteinte: decidee && !refusee,
        ),
        EtapeFrise(
          titre: l10n.suiviEtapeVenteTitre,
          detail: publiee
              ? l10n.suiviEtapeVenteDetail
              : l10n.suiviEtapeVenteAVenirDetail,
          atteinte: publiee,
        ),
      ],
    ];
  }
}
