import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/commande.dart';

final commandeRepositoryProvider = Provider<CommandeRepository>((ref) {
  return CommandeRepository();
});

/// Commandes de la cliente connectée.
final mesCommandesProvider = FutureProvider<List<Commande>>((ref) {
  return ref.watch(commandeRepositoryProvider).getMesCommandes();
});

/// Une commande précise, par son numéro.
final commandeProvider =
    FutureProvider.family<Commande?, String>((ref, numero) {
  return ref.watch(commandeRepositoryProvider).getParNumero(numero);
});

/// Accès aux commandes.
///
/// TODO(backend): remplacer les données simulées par les appels API. La forme
/// des méthodes est déjà celle attendue côté écrans, seule l'implémentation
/// changera.
class CommandeRepository {
  Future<List<Commande>> getMesCommandes() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _commandesSimulees;
  }

  Future<Commande?> getParNumero(String numero) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (final c in _commandesSimulees) {
      if (c.numero == numero) return c;
    }
    return null;
  }
}

final List<Commande> _commandesSimulees = [
  Commande(
    numero: 'CE-2641',
    statut: StatutCommande.livree,
    dateDepot: DateTime(2026, 7, 8, 15, 30),
    livraison: 3500,
    adresseLivraison: 'YAOUNDE : Rond point Bastos',
    lignes: const [
      LigneCommande(
        articleId: '1',
        maison: 'Maison Coco Chanel',
        nom: 'Robe Elégante Durable',
        prix: 38500,
        etat: 'excellent',
      ),
    ],
  ),
  Commande(
    numero: 'CE-2315',
    statut: StatutCommande.enRoute,
    dateDepot: DateTime(2026, 7, 8, 15, 30),
    estimation: DateTime(2026, 7, 11, 20, 30),
    livraison: 3500,
    adresseLivraison: 'YAOUNDE : Rond point Bastos',
    lignes: const [
      LigneCommande(
        articleId: '2',
        maison: 'Maison Coco Chanel',
        nom: 'Sac Cuir Chanel',
        prix: 31000,
        etat: 'excellent',
      ),
    ],
  ),
  Commande(
    numero: 'CE-6458',
    statut: StatutCommande.preparation,
    dateDepot: DateTime(2026, 7, 9, 9, 10),
    livraison: 3500,
    adresseLivraison: 'YAOUNDE : Rond point Bastos',
    lignes: const [
      LigneCommande(
        articleId: '3',
        maison: 'Maison Zara',
        nom: 'Veste Tweed Crème',
        prix: 25000,
        etat: 'excellent',
      ),
    ],
  ),
];
