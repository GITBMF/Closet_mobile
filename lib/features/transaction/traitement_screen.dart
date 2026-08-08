import 'package:flutter/material.dart';

import '../../core/theme/closet_colors.dart';
import 'widgets/transaction_scaffold.dart';

/// Traitement en cours — transcription de la maquette `32:756`.
///
/// Grande icône de transaction, puis anneau de chargement en bas d'écran.
/// L'écran est purement passif : il attend la fin de [operation] et bascule
/// ensuite sur [onTermine] ou [onEchec].
class TraitementScreen extends StatefulWidget {
  const TraitementScreen({
    super.key,
    required this.operation,
    required this.onTermine,
    required this.onEchec,
  });

  /// Traitement réel (appel au backend).
  final Future<void> Function() operation;

  final VoidCallback onTermine;
  final ValueChanged<Object> onEchec;

  @override
  State<TraitementScreen> createState() => _TraitementScreenState();
}

class _TraitementScreenState extends State<TraitementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _lancer());
  }

  Future<void> _lancer() async {
    try {
      await widget.operation();
      if (mounted) widget.onTermine();
    } catch (e) {
      if (mounted) widget.onEchec(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const TransactionScaffold(
      titre: 'Traitement en cours',
      child: Column(
        children: [
          SizedBox(height: 62),
          TexteTransaction(
            'Veuillez patienter quelques instants pendant que nous traitons '
            'votre opération.',
          ),
          SizedBox(height: 104),
          Icon(
            Icons.swap_horiz_rounded,
            size: 86,
            color: Colors.white,
          ),
          Spacer(),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 34),
        ],
      ),
    );
  }
}

/// Écran de succès — transcription de la maquette `32:813`.
///
/// Carte blanche en arche (217 × 275, coins supérieurs à 159) cerclée d'or,
/// coche verte, « C'est tout bon ! », puis deux boutons.
class SuccesScreen extends StatelessWidget {
  const SuccesScreen({
    super.key,
    required this.onVoirRecu,
    required this.onRetour,
  });

  final VoidCallback onVoirRecu;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      titre: 'Transaction reussie !',
      child: Column(
        children: [
          const SizedBox(height: 47),
          const _ArcheSucces(),
          const SizedBox(height: 38),
          const TexteTransaction('Votre opération a été effectuée avec succès.'),
          const Spacer(),
          BoutonTransaction(label: 'Voir le reçu', onPressed: onVoirRecu),
          const SizedBox(height: 24),
          BoutonTransaction(
            label: 'Retour dans Mon Espace',
            dore: false,
            onPressed: onRetour,
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

class _ArcheSucces extends StatelessWidget {
  const _ArcheSucces();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 275,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ClosetColors.fond300),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: ClosetColors.vert,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 44, color: Colors.white),
          ),
          const Spacer(),
          Text(
            'C’est tout bon !',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
