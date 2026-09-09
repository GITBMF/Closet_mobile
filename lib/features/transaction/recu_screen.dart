import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_app_bar.dart';
import 'transaction_models.dart';
import 'widgets/transaction_scaffold.dart';

/// Reçu de transaction — `32:865` pour un retrait, `162:3473` pour un achat.
///
/// Ticket blanc de 310 de large (rayon 30) listant les informations de
/// l'opération, puis une seconde carte portant le total en EB Garamond doré.
///
/// Les deux reçus de la maquette partagent ce gabarit à l'identique et ne
/// diffèrent que par le corps : mode de retrait, compte et receveur d'un côté,
/// description de la pièce achetée de l'autre. Ce corps arrive donc par
/// [DemandeTransaction.lignesRecu], ce qui évite d'entretenir deux écrans.
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

    return TransactionScaffold(
      titre: 'Votre reçu de transaction',
      hautTitre: 73,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 26, bottom: AppSpacing.p16),
        child: Column(
          children: [
            _Ticket(
              children: [
                Text(
                  'Transaction numéro #${recu.numero}',
                  style: ClosetTextStyles.meta.copyWith(
                    color: ClosetColors.champPlaceholder,
                  ),
                ),
                const SizedBox(height: AppSpacing.p16),
                const Divider(color: ClosetColors.champPlaceholder, height: 1),
                const SizedBox(height: AppSpacing.p16),
                _Ligne('Date & heure', _formatDate(recu.horodatage)),
                if (d.type.afficheReference)
                  _Ligne('Numéro de référence', recu.reference),
                for (final ligne in d.lignesRecu)
                  _Ligne(ligne.libelle, ligne.valeur),
                if (d.note != null && d.note!.isNotEmpty)
                  _Ligne('Note(s)', d.note!),
                const SizedBox(height: AppSpacing.p20),
                Text(
                  'ClosEt vous remercie !',
                  style: ClosetTextStyles.sousTitre.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.p16),
            _Ticket(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      d.type.libelleTotal,
                      style: ClosetTextStyles.corps.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.vert,
                      ),
                    ),
                    Text(
                      formatPrixFcfa(d.montant),
                      style: ClosetTextStyles.montantHero.copyWith(
                        fontSize: 25,
                        color: ClosetColors.fond400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 38),
            BoutonTransaction(
              label: 'Partager Mon Reçu',
              dore: false,
              onPressed: onPartager,
            ),
            const SizedBox(height: AppSpacing.p24),
            BoutonTransaction(
              label: d.type.libelleSortie,
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

/// Carte blanche du reçu : 310 de large, rayon 30.
class _Ticket extends StatelessWidget {
  const _Ticket({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 310,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p24,
          vertical: AppSpacing.p24,
        ),
        decoration: BoxDecoration(
          color: ClosetColors.blanc,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(children: children),
      ),
    );
  }
}

/// Ligne du reçu : libellé vert à gauche, valeur en gras à droite.
class _Ligne extends StatelessWidget {
  const _Ligne(this.label, this.valeur);

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p16),
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
