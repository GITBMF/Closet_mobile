import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../features/checkout/brouillon_commande.dart';
import '../../features/transaction/transaction_flow_screen.dart';
import '../../features/transaction/transaction_models.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/commande.dart';
import 'auth_repository.dart';
import 'cart_repository.dart';
import 'commande_repository.dart';

final transactionExecuteurProvider = Provider<ExecuteurTransaction>((ref) {
  return (demande, pin, [l10n]) =>
      TransactionRepository(ref).executer(demande, pin, l10n);
});

class TransactionRepository {
  TransactionRepository(this._ref);

  final Ref _ref;

  BffClient get _client => _ref.read(bffClientProvider);

  Future<RecuTransaction> executer(
    DemandeTransaction demande,
    String? pin, [
    ClosetL10n? l10n,
  ]) async {
    return switch (demande.type) {
      TypeOperation.retrait => _retirer(l10n),
      TypeOperation.paiement => _payer(demande, l10n),
    };
  }

  Future<RecuTransaction> _retirer([ClosetL10n? l10n]) async {
    throw TransactionRefusee(
      (l10n ?? ClosetL10n.fr).retraitsVersesParClosetMessage,
    );
  }

  Future<RecuTransaction> _payer(
    DemandeTransaction demande, [
    ClosetL10n? l10n,
  ]) async {
    final pieces = _ref.read(cartListProvider);
    if (pieces.isEmpty) {
      throw TransactionRefusee((l10n ?? ClosetL10n.fr).selectionVideMessage);
    }

    final brouillon = _ref.read(brouillonCommandeProvider);
    final user = _ref.read(currentUserProvider);

    final commande =
        await _ref.read(commandeRepositoryProvider).creerDepuisBrouillon(
              brouillon: brouillon,
              pieceIds: [for (final p in pieces) p.id],
              email: user?.email,
            );

    if (commande.statut == StatutCommande.devis || commande.totalCalcule <= 0) {
      throw TransactionRefusee((l10n ?? ClosetL10n.fr).livraisonADevisMessage);
    }

    final initiation = await _client.postJson('/payments/initiate', data: {
      'order_number': commande.numero,
      'customer_phone': brouillon.telephone,
      if (user?.email.isNotEmpty ?? false) 'customer_email': user!.email,
      'operator': demande.moyen,
    });

    final paymentId = chaineDe(initiation['id']);
    final urlPaiement = chaineDe(initiation['payment_url']);
    if (urlPaiement.isNotEmpty) {
      final uri = Uri.tryParse(urlPaiement);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    final paiement = await _attendreConfirmation(paymentId, l10n);
    final statut = chaineDe(paiement['status']);
    if (statut != 'succeeded') {
      throw TransactionRefusee(
        chaineDe(
          paiement['failure_reason'],
          (l10n ?? ClosetL10n.fr).paiementEchoueMessage,
        ),
      );
    }

    _ref.read(cartProvider.notifier).clear();
    _ref.read(brouillonCommandeProvider.notifier).reinitialiser();
    _ref.invalidate(mesCommandesProvider);

    return RecuTransaction(
      demande: demande,
      numero: chaineDe(paiement['id'], paymentId),
      reference: chaineDe(paiement['provider_reference'], commande.numero),
      horodatage: dateDe(paiement['confirmed_at']) ?? DateTime.now(),
      numeroCommande: commande.numero,
    );
  }

  Future<Map<String, dynamic>> _attendreConfirmation(
    String paymentId, [
    ClosetL10n? l10n,
  ]) async {
    if (paymentId.isEmpty) {
      throw TransactionRefusee(
        (l10n ?? ClosetL10n.fr).serveurPasIdentifiantPaiementMessage,
      );
    }

    const delai = Duration(seconds: 2);
    const tentatives = 30;
    for (var i = 0; i < tentatives; i++) {
      final json = await _client.getJson('/payments/$paymentId');
      final statut = chaineDe(json['status']);
      if (statut == 'succeeded' ||
          statut == 'failed' ||
          statut == 'refunded') {
        return json;
      }
      await Future<void>.delayed(delai);
    }
    throw TransactionRefusee(
      (l10n ?? ClosetL10n.fr).paiementEnCoursOperateurMessage,
    );
  }
}
