import 'package:flutter/material.dart';

import '../../core/constants/vocabulary.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_app_bar.dart';
import 'transaction_models.dart';
import 'widgets/transaction_scaffold.dart';

/// Reçu de transaction — ticket unique, logo ClosEt, total doré.
class RecuScreen extends StatelessWidget {
  const RecuScreen({
    super.key,
    required this.recu,
    required this.onPartager,
    required this.onRetour,
  });

  final RecuTransaction recu;
  final VoidCallback onPartager;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    final d = recu.demande;
    final piece = recu.piece;

    return TransactionScaffold(
      titre: 'Votre reçu de transaction',
      hautTitre: 64,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: AppSpacing.p16),
        child: Column(
          children: [
            _Ticket(
              children: [
                const _LogoCloset(),
                const SizedBox(height: AppSpacing.p12),
                Text(
                  'Transaction numéro  #${recu.numero}',
                  style: ClosetTextStyles.meta.copyWith(
                    color: ClosetColors.taupe,
                  ),
                ),
                const SizedBox(height: AppSpacing.p16),
                const _LignePointillee(),
                const SizedBox(height: AppSpacing.p16),
                _Ligne('Date & heure', _formatDate(recu.horodatage)),
                if (piece != null) ...[
                  _Ligne('Marque de la pièce', piece.marque),
                  _Ligne('Catégorie', piece.categorie),
                  _Ligne('Taille', piece.taille),
                  _Ligne('Etat de la pièce', piece.etat),
                  _Ligne('Mode de paiement', d.moyen),
                  _Ligne('Livraison', piece.livraison),
                ] else ...[
                  _Ligne(d.type.libelleMode, d.moyen),
                  _Ligne('Compte Numéro', d.compteMasque),
                  _Ligne('Nom du receveur', d.beneficiaire),
                  if (d.note != null) _Ligne('Note(s)', d.note!),
                ],
                const _LignePointillee(),
                const SizedBox(height: AppSpacing.p16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      d.type.libelleTotal,
                      style: ClosetTextStyles.corps.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ClosetColors.vert,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatPrixFcfa(d.montant),
                      style: ClosetTextStyles.montantHero.copyWith(
                        fontSize: 26,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.fond400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p16),
                Text(
                  'ClosEt vous remercie !',
                  style: ClosetTextStyles.sousTitre.copyWith(
                    fontStyle: FontStyle.italic,
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _BoutonPartage(onPressed: onPartager),
            const SizedBox(height: AppSpacing.p16),
            BoutonTransaction(
              label: Vocabulary.ctaContinue,
              onPressed: onRetour,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const mois = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final suffixe = d.hour < 12 ? 'AM' : 'PM';
    final mm = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]}, '
        '$h:$mm:$ss $suffixe';
  }
}

class _LogoCloset extends StatelessWidget {
  const _LogoCloset();

  @override
  Widget build(BuildContext context) {
    final base = ClosetTextStyles.display.copyWith(
      fontSize: 22,
      letterSpacing: 1.4,
      color: ClosetColors.vert,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('CL', style: base),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: const Icon(
            Icons.checkroom_outlined,
            size: 20,
            color: ClosetColors.vert,
          ),
        ),
        Text('S', style: base),
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(
            'ET',
            style: base.copyWith(
              fontSize: 11,
              color: ClosetColors.fond400,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _LignePointillee extends StatelessWidget {
  const _LignePointillee();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 5.0;
        const gap = 4.0;
        final n = (c.maxWidth / (dash + gap)).floor();
        return Row(
          children: [
            for (var i = 0; i < n; i++) ...[
              Container(
                width: dash,
                height: 1,
                color: ClosetColors.ligne,
              ),
              if (i < n - 1) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}

class _Ticket extends StatelessWidget {
  const _Ticket({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 310,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne(this.label, this.valeur);

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ClosetTextStyles.corps.copyWith(color: ClosetColors.vert),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            child: Text(
              valeur,
              textAlign: TextAlign.right,
              style: ClosetTextStyles.corps.copyWith(
                fontWeight: FontWeight.w600,
                color: ClosetColors.noir,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonPartage extends StatelessWidget {
  const _BoutonPartage({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return Center(
      child: SizedBox(
        width: 312,
        height: 44,
        child: Material(
          color: ClosetColors.vertFonce,
          shape: RoundedRectangleBorder(
            borderRadius: rayon,
            side: const BorderSide(color: Colors.white, width: AppStroke.fin),
          ),
          child: InkWell(
            borderRadius: rayon,
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ios_share_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Partager Mon Reçu',
                  style: ClosetTextStyles.bouton.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
