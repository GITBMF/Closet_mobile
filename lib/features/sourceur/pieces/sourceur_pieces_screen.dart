import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Filtres de la maquette `35:1895`.
enum _FiltreDepot { toutes, enVente, enAnalyse }

/// Mes dépôts — transcription de la maquette `35:1895`.
///
/// Deux tuiles de synthèse vert profond (165 × 101), puis la liste des pièces
/// confiées en cartes blanches de 354 × 106 cerclées d'or.
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
    final pieces = ref.watch(mesPiecesProvider);
    final revenus = ref.watch(revenusSourceurProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Mes dépôts',
              onRetour: () => context.go('/sourceur/espace'),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/espace/alertes'),
                ),
              ],
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
                      Row(
                        children: [
                          Expanded(
                            child: _TuileSynthese(
                              icone: Icons.account_balance_wallet_outlined,
                              label: 'A reverser',
                              valeur: revenus.maybeWhen(
                                data: (r) => 'TOTAL : '
                                    '${formatPrixFcfa(r.enAttente.toDouble())}',
                                orElse: () => 'TOTAL : —',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.p20),
                          Expanded(
                            child: _TuileSynthese(
                              icone: Icons.sell_outlined,
                              label: 'Pièces en vente',
                              valeur: 'TOTAL : '
                                  '${liste.where((p) => p.statut == StatutPiece.publiee).length.toString().padLeft(2, '0')} '
                                  'pièces',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ClosetChip(
                              label: 'Toutes. ${liste.length}',
                              isActive: _filtre == _FiltreDepot.toutes,
                              onTap: () => setState(
                                () => _filtre = _FiltreDepot.toutes,
                              ),
                            ),
                            const SizedBox(width: 11),
                            ClosetChip(
                              label: 'En vente',
                              isActive: _filtre == _FiltreDepot.enVente,
                              onTap: () => setState(
                                () => _filtre = _FiltreDepot.enVente,
                              ),
                            ),
                            const SizedBox(width: 11),
                            ClosetChip(
                              label: 'En cours d’analyse',
                              isActive: _filtre == _FiltreDepot.enAnalyse,
                              onTap: () => setState(
                                () => _filtre = _FiltreDepot.enAnalyse,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p20),
                      if (visibles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Text(
                              'Aucune pièce dans cette catégorie.',
                              style: ClosetTextStyles.citation.copyWith(
                                color: ClosetColors.taupe,
                              ),
                            ),
                          ),
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

/// Tuile de synthèse : 165 × 101, vert profond, icône blanche de 36.
class _TuileSynthese extends StatelessWidget {
  const _TuileSynthese({
    required this.icone,
    required this.label,
    required this.valeur,
  });

  final IconData icone;
  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 101),
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icone, size: 18, color: ClosetColors.vert),
          ),
          const SizedBox(height: AppSpacing.p12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.actionPetite.copyWith(
              letterSpacing: 0.30,
              color: ClosetColors.fond300,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valeur,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.corps.copyWith(color: Colors.white),
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

  /// Le badge suit les statuts de la maquette `36:2063`.
  StatusBadge get _badge => switch (piece.statut) {
        StatutPiece.publiee => StatusBadge.miseEnVente(),
        StatutPiece.enRevue => StatusBadge.enAnalyse(),
        StatutPiece.vendue => StatusBadge.livree('Vendue'),
        StatutPiece.refusee => StatusBadge.refusee(),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.all(AppSpacing.p12),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    ? const ColoredBox(color: Color(0xFFD9D9D9))
                    : CachedNetworkImage(
                        imageUrl: piece.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
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
                    '${piece.univers} · ${formatPrixFcfa(piece.prix)}',
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
