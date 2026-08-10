import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

/// Habillage commun aux quatre écrans du tunnel de transaction
/// (`32:704`, `32:756`, `32:813`, `32:865`).
///
/// Fond vert profond, titre EB Garamond blanc centré, et mention de
/// chiffrement en pied d'écran.
class TransactionScaffold extends StatelessWidget {
  const TransactionScaffold({
    super.key,
    this.titre,
    required this.child,
    this.hautTitre = 124,
    this.mention = mentionChiffrement,
  });

  /// Titre d'écran. `null` = pas de titre (cas de `36:2064`).
  final String? titre;

  final Widget child;

  /// Position verticale du titre. 124 dans la maquette, 73 pour le reçu.
  final double hautTitre;

  /// Mention de pied d'écran, remplaçable (cf. `36:2113`).
  final String mention;

  /// Mention reprise à l'identique sur les écrans de transaction.
  static const String mentionChiffrement =
      'Toutes vos informations sont chiffrées de bout en bout et stockées '
      'sur des serveurs sécurisés.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: hautTitre - 47),
            if (titre != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                child: Text(
                  titre!,
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.sousTitre.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, AppSpacing.p20),
              child: Text(
                mention,
                textAlign: TextAlign.center,
                style: ClosetTextStyles.meta.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.22,
                  color: ClosetColors.noteChiffrement,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Texte d'explication des écrans de transaction : Lato 500 / 16, crème,
/// centré sur 343 de large.
class TexteTransaction extends StatelessWidget {
  const TexteTransaction(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        style: ClosetTextStyles.citation.copyWith(
          fontFamily: ClosetTextStyles.libelle.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ClosetColors.beige,
        ),
      ),
    );
  }
}

/// Bouton pleine largeur du tunnel : 312 × 44, rayon 100.
///
/// En version dorée pour l'action principale, en version cerclée de blanc
/// sur fond vert pour l'action secondaire.
class BoutonTransaction extends StatelessWidget {
  const BoutonTransaction({
    super.key,
    required this.label,
    required this.onPressed,
    this.dore = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool dore;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return Center(
      child: SizedBox(
        width: 312,
        height: 44,
        child: Material(
          color: dore ? ClosetColors.fond300 : ClosetColors.vert,
          borderRadius: rayon,
          shape: dore
              ? null
              : RoundedRectangleBorder(
                  borderRadius: rayon,
                  side: const BorderSide(
                    color: Colors.white,
                    width: AppStroke.fin,
                  ),
                ),
          child: InkWell(
            borderRadius: rayon,
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: ClosetTextStyles.bouton.copyWith(
                  color: dore ? ClosetColors.vert : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
