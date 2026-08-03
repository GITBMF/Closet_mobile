import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_app_bar.dart';

/// Liste des dépôts du sourceur (/sourceur/pieces)
class SourceurPiecesScreen extends ConsumerStatefulWidget {
  const SourceurPiecesScreen({super.key});

  @override
  ConsumerState<SourceurPiecesScreen> createState() =>
      _SourceurPiecesScreenState();
}

class _SourceurPiecesScreenState extends ConsumerState<SourceurPiecesScreen> {
  static const _filtres = [
    (label: 'Toutes', statut: null),
    (label: 'En revue', statut: StatutPiece.enRevue),
    (label: 'Publiée', statut: StatutPiece.publiee),
    (label: 'Vendue', statut: StatutPiece.vendue),
    (label: 'Refusée', statut: StatutPiece.refusee),
  ];

  StatutPiece? _filtre;

  @override
  Widget build(BuildContext context) {
    final piecesAsync = ref.watch(mesPiecesProvider);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const SourceurAppBar(
        title: 'Mes dépôts',
        subtitle: 'VOS PIÈCES EN DÉPÔT',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltres(),
          Expanded(
            child: piecesAsync.when(
              data: (pieces) {
                final filtered = _filtre == null
                    ? pieces
                    : pieces.where((p) => p.statut == _filtre).toList();
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: filtered.isEmpty
                      ? _buildAucunePiece(context, cs)
                      : Column(
                          children: filtered
                              .map((p) => _PieceCard(piece: p))
                              .toList(),
                        ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: ClosetColors.dore),
              ),
              error: (e, _) => Center(
                child: Text('Erreur de chargement',
                    style: ClosetTextStyles.corps),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Material(
        color: ClosetColors.dore,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.go('/sourceur/nouvelle'),
          child: const SizedBox(
            width: 58,
            height: 58,
            child: Icon(Icons.add, size: 24, color: ClosetColors.noir),
          ),
        ),
      ),
    );
  }


  Widget _buildFiltres() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          for (final f in _filtres) ...[
            ClosetChip(
              label: f.label,
              selectionnee: _filtre == f.statut,
              onTap: () => setState(() => _filtre = f.statut),
            ),
            if (f != _filtres.last) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildAucunePiece(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClosetColors.dore.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.photo_camera_outlined,
              size: 32, color: cs.onSurface.withValues(alpha: 0.45)),
          const SizedBox(height: 18),
          Text(
            'Aucune pièce pour le moment.',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.corps.copyWith(
              fontStyle: FontStyle.italic,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          ClosetPrimaryButton(
            label: 'Déposer une pièce',
            icone: Icons.add,
            onPressed: () => context.go('/sourceur/nouvelle'),
          ),
        ],
      ),
    );
  }
}

/// Carte affichant une pièce déposée
class _PieceCard extends StatelessWidget {
  final PieceDeposee piece;
  const _PieceCard({required this.piece});

  Color _statutBg() {
    switch (piece.statut) {
      case StatutPiece.publiee:
        return ClosetColors.fondsSucces;
      case StatutPiece.vendue:
        return ClosetColors.conditionExcellentFond;
      case StatutPiece.refusee:
        return ClosetColors.fondsErreur;
      case StatutPiece.enRevue:
        return ClosetColors.fondsAlerte;
    }
  }

  Color _statutFg() {
    switch (piece.statut) {
      case StatutPiece.publiee:
        return ClosetColors.succes;
      case StatutPiece.vendue:
        return ClosetColors.doreEncre;
      case StatutPiece.refusee:
        return ClosetColors.erreur;
      case StatutPiece.enRevue:
        return ClosetColors.alerte;
    }
  }

  String _statutLabel() {
    switch (piece.statut) {
      case StatutPiece.publiee:
        return 'Publiée';
      case StatutPiece.vendue:
        return 'Vendue';
      case StatutPiece.refusee:
        return 'Refusée';
      case StatutPiece.enRevue:
        return 'En revue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Miniature
          Container(
            width: 60,
            height: 76,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: piece.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: piece.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: cs.onSurface.withValues(alpha: 0.07),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported,
                        color: cs.onSurface.withValues(alpha: 0.35),
                      ),
                      fadeInDuration: const Duration(milliseconds: 250),
                    ),
                  )
                : Icon(Icons.image_not_supported,
                    color: cs.onSurface.withValues(alpha: 0.35)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(piece.nom,
                    style: ClosetTextStyles.saisie.copyWith(
                        fontSize: 14, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(piece.univers,
                    style: ClosetTextStyles.corps
                        .copyWith(color: cs.onSurface.withValues(alpha: 0.55))),
                const SizedBox(height: 8),
                Text(
                  '${piece.prix.toInt()} FCFA',
                  style: ClosetTextStyles.saisie.copyWith(
                      fontSize: 15, color: cs.onSurface),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statutBg(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statutLabel(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _statutFg(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
