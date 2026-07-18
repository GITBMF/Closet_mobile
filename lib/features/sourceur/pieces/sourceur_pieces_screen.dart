import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/bordure_pointillee.dart';
import '../../../core/widgets/closet_bottom_nav.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_header.dart';
import '../nouvelle/sourceur_nouvelle_piece_screen.dart';

/// Statuts possibles d'une pièce déposée par le sourceur.
enum StatutPiece { enRevue, publiee, vendue, refusee }

/// Une pièce déposée (modèle provisoire en attendant le backend).
class PieceDeposee {
  const PieceDeposee({required this.nom, required this.statut});

  final String nom;
  final StatutPiece statut;
}

/// Liste des dépôts du sourceur (/sourceur/pieces),
/// filtrable par statut.
class SourceurPiecesScreen extends StatefulWidget {
  const SourceurPiecesScreen({super.key, this.pieces = const []});

  final List<PieceDeposee> pieces;

  @override
  State<SourceurPiecesScreen> createState() => _SourceurPiecesScreenState();
}

class _SourceurPiecesScreenState extends State<SourceurPiecesScreen> {
  static const _filtres = [
    (label: 'Toutes', statut: null),
    (label: 'En revue', statut: StatutPiece.enRevue),
    (label: 'Publiée', statut: StatutPiece.publiee),
    (label: 'Vendue', statut: StatutPiece.vendue),
    (label: 'Refusée', statut: StatutPiece.refusee),
  ];

  StatutPiece? _filtre;

  List<PieceDeposee> get _piecesFiltrees => _filtre == null
      ? widget.pieces
      : widget.pieces.where((p) => p.statut == _filtre).toList();

  void _ouvrirDepot() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SourceurNouvellePieceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ClosetHeader(
              titre: 'Mes dépôts',
              wishlistCount: 2,
              panierCount: 2,
              notificationsCount: 7,
            ),
            _buildFiltres(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: _piecesFiltrees.isEmpty
                    ? _buildAucunePiece()
                    // TODO: afficher les cartes de pièces quand le backend
                    // fournira les dépôts (photo, nom, statut, prix).
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Material(
        color: ClosetColors.dore,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _ouvrirDepot,
          child: const SizedBox(
            width: 72,
            height: 72,
            child: Icon(Icons.add, size: 30, color: ClosetColors.noir),
          ),
        ),
      ),
      bottomNavigationBar: ClosetBottomNav(indexActif: -1, onTap: (_) {}),
    );
  }

  Widget _buildFiltres() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildAucunePiece() {
    return BordurePointillee(
      couleur: ClosetColors.dore.withValues(alpha: 0.45),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        child: Column(
          children: [
            const Icon(Icons.photo_camera_outlined,
                size: 40, color: ClosetColors.texteSecondaire),
            const SizedBox(height: 18),
            Text(
              'Aucune pièce pour le moment.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corps.copyWith(
                fontStyle: FontStyle.italic,
                color: ClosetColors.texteSecondaire,
              ),
            ),
            const SizedBox(height: 24),
            ClosetPrimaryButton(
              label: 'Déposer une pièce',
              icone: Icons.add,
              onPressed: _ouvrirDepot,
            ),
          ],
        ),
      ),
    );
  }
}
