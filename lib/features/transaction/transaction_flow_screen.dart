import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/toasts.dart';
import 'pin_screen.dart';
import 'recu_screen.dart';
import 'traitement_screen.dart';
import 'transaction_models.dart';

/// Étapes du tunnel, dans l'ordre de la maquette.
enum _EtapeTunnel { pin, traitement, succes, recu }

/// Exécute réellement l'opération et renvoie le reçu émis par le serveur.
///
/// Le reçu **doit** venir du backend : son numéro et sa référence sont des
/// identifiants financiers, ils ne peuvent pas être fabriqués côté client.
///
/// [pin] n'est renseigné que pour un retrait sourceur ; il est nul pour un
/// paiement acheteuse, qui ne passe pas par un code.
typedef ExecuteurTransaction = Future<RecuTransaction> Function(
  DemandeTransaction demande,
  String? pin,
);

/// Tunnel de transaction — orchestre `32:704` → `32:756` → `32:813` → `32:865`
/// côté retrait, et `162:5220` → `162:3351` → `162:3473` côté paiement.
///
/// Les étapes vivent dans **une seule route**. C'est volontaire : une fois
/// l'opération partie au backend, revenir en arrière n'a plus de sens.
/// `PopScope` bloque donc le retour dès l'étape traitement, ce qu'un
/// empilement de routes séparées aurait laissé passer.
///
/// Le nombre d'étapes dépend de l'opération : quatre pour un retrait, qui
/// commence par un code PIN, trois pour un paiement, qui n'en a pas
/// (cf. [ComportementOperation.exigePin]).
class TransactionFlowScreen extends ConsumerStatefulWidget {
  const TransactionFlowScreen({
    super.key,
    required this.demande,
    required this.executer,
  });

  final DemandeTransaction demande;

  /// Traitement réel. **Obligatoire** : le tunnel ne doit jamais pouvoir
  /// afficher « Transaction réussie » sans qu'une opération ait eu lieu.
  final ExecuteurTransaction executer;

  @override
  ConsumerState<TransactionFlowScreen> createState() =>
      _TransactionFlowScreenState();
}

class _TransactionFlowScreenState extends ConsumerState<TransactionFlowScreen> {
  late _EtapeTunnel _etape = _etapeInitiale;

  /// Code PIN, conservé le temps d'un seul appel puis effacé.
  String? _pin;

  RecuTransaction? _recu;

  /// Un paiement acheteuse n'a pas d'écran PIN : le tunnel démarre directement
  /// sur le traitement.
  _EtapeTunnel get _etapeInitiale =>
      widget.demande.type.exigePin ? _EtapeTunnel.pin : _EtapeTunnel.traitement;

  bool get _retourAutorise => _etape == _EtapeTunnel.pin;

  void _validerPin(String pin) {
    setState(() {
      _pin = pin;
      _etape = _EtapeTunnel.traitement;
    });
  }

  Future<void> _executer() async {
    final pin = _pin;
    if (widget.demande.type.exigePin && pin == null) {
      throw StateError('Code PIN absent : opération refusée.');
    }
    try {
      // TODO(backend): appeler widget.executer une fois l'API branchée.
      // On simule ici pour que le parcours PIN → traitement → succès →
      // reçu fonctionne sans redémarrer le routeur.
      _recu = await simulerTransaction(widget.demande, pin);
    } finally {
      // Le PIN ne survit pas à l'appel, quel qu'en soit le résultat.
      _pin = null;
    }
  }

  void _surSucces() => setState(() => _etape = _EtapeTunnel.succes);

  void _surEchec(Object erreur) {
    if (!mounted) return;
    _pin = null;
    final message = messageErreurTransaction(erreur);

    if (widget.demande.type.exigePin) {
      // Le retrait revient à la saisie du PIN : c'est l'étape rejouable.
      setState(() => _etape = _EtapeTunnel.pin);
    } else {
      // Un paiement n'a pas d'étape rejouable dans le tunnel — le rejouer sur
      // place relancerait l'opération en boucle. On rend la main au checkout,
      // où la cliente peut corriger son moyen de paiement.
      context.pop();
    }

    toastErreur(ref, message, titre: 'Transaction refusée');
  }

  void _quitter() => context.go(widget.demande.type.routeRetour);

  @override
  void dispose() {
    _pin = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _retourAutorise,
      child: switch (_etape) {
        _EtapeTunnel.pin => PinScreen(
            demande: widget.demande,
            onValide: _validerPin,
          ),
        _EtapeTunnel.traitement => TraitementScreen(
            type: widget.demande.type,
            operation: _executer,
            onTermine: _surSucces,
            onEchec: _surEchec,
          ),
        _EtapeTunnel.succes => SuccesScreen(
            recu: _recu!,
            onVoirRecu: () => setState(() => _etape = _EtapeTunnel.recu),
            onRetour: _quitter,
          ),
        _EtapeTunnel.recu => RecuScreen(
            recu: _recu!,
            onPartager: () => toastInfo(
              ref,
              'Partage indisponible',
              'Le partage du reçu n’est pas encore proposé par le serveur.',
            ),
            onRetour: _quitter,
          ),
      },
    );
  }
}

/// Message d'erreur affichable.
///
/// Ne rend jamais l'exception brute : elle peut porter une URL interne, une
/// trace ou un identifiant de compte. L'utilisateur reçoit un message neutre.
String messageErreurTransaction(Object erreur) {
  if (erreur is TransactionRefusee) return erreur.message;
  return "L'opération n'a pas abouti. Aucun montant n'a été débité. "
      'Veuillez réessayer.';
}

/// Simulation locale du backend — à remplacer par l'appel HTTP réel.
Future<RecuTransaction> simulerTransaction(
  DemandeTransaction demande,
  String pin,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 2200));
  if (pin.length != 4) {
    throw const TransactionRefusee('Code PIN incorrect.');
  }
  return RecuTransaction(
    demande: demande,
    numero: '8512857525',
    reference: '44277436886',
    horodatage: DateTime.now(),
  );
}

/// Refus explicite renvoyé par le backend, dont le message est sûr à afficher
/// (« solde insuffisant », « code PIN incorrect »…).
class TransactionRefusee implements Exception {
  const TransactionRefusee(this.message);

  final String message;

  @override
  String toString() => 'TransactionRefusee: $message';
}
