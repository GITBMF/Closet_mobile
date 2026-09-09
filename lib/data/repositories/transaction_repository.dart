import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
  return (demande, pin) => TransactionRepository(ref).executer(demande, pin);
});

class TransactionRepository {
  TransactionRepository(this._ref);

  final Ref _ref;

  BffClient get _client => _ref.read(bffClientProvider);

  Future<RecuTransaction> executer(
    DemandeTransaction demande,
    String? pin,
  ) async {
    return switch (demande.type) {
      TypeOperation.retrait => _retirer(),
      TypeOperation.paiement => _payer(demande),
    };
  }

  Future<RecuTransaction> _retirer() async {
    throw const TransactionRefusee(
      'Les retraits sont versés par ClosET une fois vos pièces vendues.',
    );
  }

  Future<RecuTransaction> _payer(DemandeTransaction demande) async {
    final pieces = _ref.read(cartListProvider);
    if (pieces.isEmpty) {
      throw const TransactionRefusee('Votre sélection est vide.');
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
      throw const TransactionRefusee(
        'La livraison vers cette zone est à devis. Nous vous contacterons '
        'sur WhatsApp pour confirmer le montant avant tout paiement.',
      );
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

    final paiement = await _attendreConfirmation(paymentId);
    final statut = chaineDe(paiement['status']);
    if (statut != 'succeeded') {
      throw TransactionRefusee(
        chaineDe(
          paiement['failure_reason'],
          'Le paiement n’a pas abouti. Réessayez ou changez de moyen.',
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

  Future<Map<String, dynamic>> _attendreConfirmation(String paymentId) async {
    if (paymentId.isEmpty) {
      throw const TransactionRefusee(
        'Le serveur n’a pas renvoyé d’identifiant de paiement.',
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
    throw const TransactionRefusee(
      'Le paiement est toujours en cours chez l’opérateur. '
      'Vérifiez « Mes commandes » dans un instant.',
    );
  }
}
