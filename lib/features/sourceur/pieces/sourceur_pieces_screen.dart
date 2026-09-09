import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../sourceur_layout.dart';
import '../widgets/sourceur_header.dart';

/// Filtres de la maquette `35:1895`.
enum _FiltreDepot { toutes, enVente, enAnalyse }

/// Mes d�p�ts � transcription de la maquette `35:1895`.
///
/// Deux tuiles de synth�se vert profond (165 � 101), puis la liste des pi�ces
/// confi�es en cartes blanches de 354 � 106 cercl�es d'or.
class SourceurPiecesScreen extends ConsumerStatefulWidget {
  const SourceurPiecesScreen({super.key});

  @override
  ConsumerState<SourceurPiecesScreen> createState() =>
      _SourceurPiecesScreenState();
}

class _SourceurPiecesScreenState
    extends ConsumerState<SourceurPiecesScreen> {
  _FiltreDepot _filtre = _FiltreDepot.toutes;

  bool _correspond(PieceDeposee p) => switch (_filtre) {
        _FiltreDepot.toutes => true,
        _FiltreDepot.enVente => p.statut == StatutPiece.publiee,
        _FiltreDepot.enAnalyse => p.statut == StatutPiece.enRevue,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final pieces = ref.watch(mesPiecesProvider);
    final revenus = ref.watch(revenusSourceurProvider);

    ref.listen(mesPiecesProvider, (precedent, suivant) {
      signaleTransitionAsync(
        ref: ref,
        context: context,
        precedent: precedent,
        suivant: suivant,
        titre: l10n.navDepots,
        messageVide: l10n.aucuneDonnee,
        estVide: (liste) => liste.isEmpty,
      );
    });
    ref.listen(revenusSourceurProvider, (precedent, suivant) {
      signaleTransitionAsync(
        ref: ref,
        context: context,
        precedent: precedent,
        suivant: suivant,
        titre: l10n.navGains,
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: l10n.mesDepots,
              afficherRetour: false,
            ),
            Expanded(
              child: pieces.when(
                data: (liste) {
                  final visibles = liste.where(_correspond).toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.p20,
                      29,
                      AppSpacing.p20,
                      AppSpacing.p32,
                    ),
                    children: [
                      _TableauBord(
                        pieces: liste,
                        revenus: revenus,
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ClosetChip(
                              label: l10n.toutes,
                              isActive: _filtre == _FiltreDepot.toutes,
                              onTap: () => setState(
                                () => _filtre = _FiltreDepot.toutes,
                              ),
                            ),
                            const SizedBox(width: 11),
                            ClosetChip(
                              label: l10n.enVente,
                              isActive: _filtre == _FiltreDepot.enVente,
                              onTap: () => setState(
                                () => _filtre = _FiltreDepot.enVente,
                              ),
                            ),
                            const SizedBox(width: 11),
                            ClosetChip(
                              label: l10n.enCoursAnalyse,
                              isActive: _filtre == _FiltreDepot.enAnalyse,
                              onTap: () => setState(
                                () => _filtre = _FiltreDepot.enAnalyse,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p20),
                      if (liste.isEmpty)
                        ClosetListeVide(
                          titre: l10n.aucuneDonnee,
                          message: l10n.depotsVide,
                          action: () => allerOngletSourceur(
                            context,
                            OngletSourceur.confier,
                          ),
                          libelleAction: l10n.confierUnePiece,
                        )
                      else if (visibles.isEmpty)
                        ClosetListeVide(
                          message: l10n.aucunePieceFiltre,
                        )
                      else
                        for (final piece in visibles) ...[
                          _CarteDepot(
                            piece: piece,
                            onTap: () => context.push(
                              '/sourceur/piece/${piece.id}',
                            ),
                          ),
                          const SizedBox(height: 9),
                        ],
                    ],
                  );
                },
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(mesPiecesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tableau de bord : vendues, en ligne, chiffre d'affaires.
class _TableauBord extends StatelessWidget {
  const _TableauBord({required this.pieces, required this.revenus});

  final List<PieceDeposee> pieces;
  final AsyncValue<RevenusSourceur> revenus;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final vendues =
        pieces.where((p) => p.statut == StatutPiece.vendue).length;
    final enLigne =
        pieces.where((p) => p.statut == StatutPiece.publiee).length;
    final ca = revenus.maybeWhen(
      data: (r) => formatPrixFcfa((r.brut + r.enAttente).toDouble()),
      orElse: () => '—',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Kpi(
              valeur: '$vendues',
              label: l10n.vendues,
            ),
          ),
          Container(width: 1, height: 44, color: ClosetColors.emeraude300),
          Expanded(
            child: _Kpi(
              valeur: '$enLigne',
              label: l10n.enLigne,
            ),
          ),
          Container(width: 1, height: 44, color: ClosetColors.emeraude300),
          Expanded(
            child: _Kpi(
              valeur: ca,
              label: l10n.chiffreAffaires,
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.valeur, required this.label});

  final String valeur;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valeur,
              maxLines: 1,
              style: ClosetTextStyles.titreBloc.copyWith(
                color: ClosetColors.blanc,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.actionPetite.copyWith(
              color: ClosetColors.fond300,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de pièce déposée : 354 × 106, blanche cerclée d'or, visuel 70 × 82.
class _CarteDepot extends StatelessWidget {
  const _CarteDepot({required this.piece, required this.onTap});

  final PieceDeposee piece;
  final VoidCallback onTap;

  /// Le badge suit les statuts de la maquette `36:2063` et
  /// `SubmissionStatus` (`submitted` / `in_review` / `accepted` /
  /// `catalogued` / `refused`).
  StatusBadge get _badge => switch (piece.statut) {
        StatutPiece.vendue => StatusBadge.miseEnVente('Vendue'),
        _ => switch (piece.statutApi) {
            'catalogued' => StatusBadge.miseEnVente(),
            'submitted' => StatusBadge.depotRecu(),
            'refused' => StatusBadge.refusee(),
            'accepted' => StatusBadge.miseEnVente('Acceptée'),
            _ => StatusBadge.enAnalyse(),
          },
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.all(AppSpacing.p12),
        decoration: BoxDecoration(
          color: ClosetColors.blanc,
          border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 70,
                height: 82,
                child: piece.imageUrl == null
                    ? const ColoredBox(color: ClosetColors.gabaritImage)
                    : CachedNetworkImage(
                        imageUrl: piece.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: ClosetColors.gabaritImage),
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: ClosetColors.gabaritImage),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    piece.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.corpsMedium.copyWith(
                      letterSpacing: -0.24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    '${piece.univers.isEmpty ? piece.nom : piece.univers} · ${formatPrixFcfa(piece.prix)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.actionPetite.copyWith(
                      letterSpacing: -0.20,
                      color: ClosetColors.champPlaceholder,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  _badge,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
