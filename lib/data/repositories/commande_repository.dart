import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/checkout/brouillon_commande.dart';
import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/commande.dart';

final commandeRepositoryProvider = Provider<CommandeRepository>((ref) {
  return CommandeRepository(ref.watch(bffClientProvider));
});

final mesCommandesProvider = FutureProvider<List<Commande>>((ref) {
  return ref.watch(commandeRepositoryProvider).getMesCommandes();
});

final commandeProvider =
    FutureProvider.family<Commande?, String>((ref, numero) {
  return ref.watch(commandeRepositoryProvider).getParNumero(numero);
});

class CommandeRepository {
  CommandeRepository(this._client);

  final BffClient _client;

  Future<List<Commande>> getMesCommandes() async {
    final page = await _client.getJson('/orders', query: {
      'limit': 50,
      'offset': 0,
    });
    return [for (final o in objetsDe(page['items'])) Commande.fromJson(o)];
  }

  Future<Commande?> getParNumero(String numero) async {
    try {
      return Commande.fromJson(await _client.getJson('/orders/$numero'));
    } on ApiException catch (e) {
      if (e.kind == KindErreurApi.introuvable) return null;
      rethrow;
    }
  }

  Future<Commande> creerDepuisBrouillon({
    required BrouillonCommande brouillon,
    required List<String> pieceIds,
    String? email,
  }) async {
    final adresse = <String, dynamic>{
      'line1': brouillon.quartier.trim().isNotEmpty
          ? brouillon.quartier.trim()
          : brouillon.adresseResumee,
      if (brouillon.ville != null) 'city_id': brouillon.ville!.id,
      if (brouillon.region != null) 'region_id': brouillon.region!.id,
      if (brouillon.quartier.trim().isNotEmpty)
        'neighbourhood': brouillon.quartier.trim(),
    };

    final json = await _client.postJson('/orders', data: {
      'piece_ids': pieceIds,
      'customer_name': brouillon.nomComplet,
      'customer_phone': brouillon.telephone,
      if (email != null && email.isNotEmpty) 'customer_email': email,
      'address': adresse,
      if (brouillon.codePrivilege.isNotEmpty)
        'privilege_code': brouillon.codePrivilege,
    });
    return Commande.fromJson(json);
  }
}
