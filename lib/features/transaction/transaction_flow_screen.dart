import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/widgets/toasts.dart';
import 'confirmation_screen.dart';
import 'pin_screen.dart';
import 'recu_screen.dart';
import 'traitement_screen.dart';
import 'transaction_models.dart';

/// Étapes du tunnel, dans l'ordre de la maquette.
enum _EtapeTunnel { pin, confirmation, traitement, succes, recu }

/// Exécute réellement l'opération et renvoie le reçu émis par le serveur.
///
/// Le reçu **doit** venir du backend : son numéro et sa référence sont des
/// identifiants financiers, ils ne peuvent pas être fabriqués côté client.
///
/// [pin] n'est renseigné que pour un retrait sourceur ; il est nul pour un
/// paiement acheteuse, qui ne passe pas par un code.
typedef ExecuteurTransaction = Future<RecuTransaction> Function(
  DemandeTransaction demande,
  String? pin, [
  ClosetL10n? l10n,
]);

/// Tunnel de transaction — orchestre `32:704` → `32:756` → `32:813` → `32:865`
/// côté retrait, et `162:5220` → `162:3351` → `162:3473` côté paiement.
///
/// Les étapes vivent dans **une seule route**. C'est volontaire : une fois
/// l'opération partie au backend, revenir en arrière n'a plus de sens.
/// `PopScope` bloque donc le retour dès l'étape traitement, ce qu'un
/// empilement de routes séparées aurait laissé passer.
///
/// Le tunnel s'ouvre en revanche sur un récapitulatif quittable : l'opération
/// ne part qu'au geste explicite de l'utilisateur, jamais au montage.
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

  /// Sans écran PIN, le tunnel s'ouvre sur le récapitulatif : l'opération ne
  /// doit jamais partir sans un geste explicite.
  _EtapeTunnel get _etapeInitiale => widget.demande.type.exigePin
      ? _EtapeTunnel.pin
      : _EtapeTunnel.confirmation;

  /// Seules les étapes antérieures à l'engagement se quittent. Passé la
  /// confirmation, l'opération est chez le fournisseur de paiement.
  bool get _retourAutorise =>
      _etape == _EtapeTunnel.pin || _etape == _EtapeTunnel.confirmation;

  void _validerPin(String pin) {
    setState(() {
      _pin = pin;
      _etape = _EtapeTunnel.traitement;
    });
  }

  /// Engage l'opération. Point de non-retour du tunnel.
  void _confirmer() => setState(() => _etape = _EtapeTunnel.traitement);

  /// Renonce avant tout engagement et rend la main à l'écran appelant.
  void _annuler() => context.pop();

  Future<void> _executer() async {
    final pin = _pin;
    if (widget.demande.type.exigePin && pin == null) {
      throw StateError('Code PIN absent : opération refusée.');
    }
    try {
      _recu = await widget.executer(
        widget.demande,
        pin,
        ClosetL10n.of(context),
      );
    } finally {
      // Le PIN ne survit pas à l'appel, quel qu'en soit le résultat.
      _pin = null;
    }
  }

  void _surSucces() => setState(() => _etape = _EtapeTunnel.succes);

  void _surEchec(Object erreur) {
    if (!mounted) return;
    _pin = null;
    final l10n = ClosetL10n.of(context);
    final message = messageErreurTransaction(erreur, l10n);

    if (widget.demande.type.exigePin) {
      // Le retrait revient à la saisie du PIN : c'est l'étape rejouable.
      setState(() => _etape = _EtapeTunnel.pin);
    } else {
      // Un paiement n'a pas d'étape rejouable dans le tunnel — le rejouer sur
      // place relancerait l'opération en boucle. On rend la main au checkout,
      // où la cliente peut corriger son moyen de paiement.
      context.pop();
    }

    toastErreur(ref, message, titre: l10n.transactionRefuseeTitre);
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
        _EtapeTunnel.confirmation => ConfirmationScreen(
            demande: widget.demande,
            onConfirmer: _confirmer,
            onAnnuler: _annuler,
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
            onPartager: () {
              final l10n = ClosetL10n.of(context);
              toastInfo(
                ref,
                l10n.transactionPartageIndisponibleTitre,
                l10n.transactionPartageIndisponibleCorps,
              );
            },
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
String messageErreurTransaction(Object erreur, [ClosetL10n? l10n]) {
  if (erreur is TransactionRefusee) return erreur.message;
  return (l10n ?? ClosetL10n.fr).transactionEchecGenerique;
}

/// Refus explicite renvoyé par le backend, dont le message est sûr à afficher
/// (« solde insuffisant », « code PIN incorrect »…).
class TransactionRefusee implements Exception {
  const TransactionRefusee(this.message);

  final String message;

  @override
  String toString() => 'TransactionRefusee: $message';
}
