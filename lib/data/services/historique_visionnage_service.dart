import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

/// Pièces récemment consultées, pour le bandeau « Récemment vues » de
/// l'accueil. Stocke un instantané léger de la pièce (photo, titre, prix) :
/// pas besoin de rappeler le catalogue pour l'afficher, et l'historique
/// survit même si la pièce est retirée entre-temps.
class HistoriqueVisionnageService {
  static const _key = 'closet_pieces_vues_v1';
  static const max = 16;

  static Future<List<Article>> lire() async {
    final prefs = await SharedPreferences.getInstance();
    final brut = prefs.getString(_key);
    if (brut == null) return const [];
    try {
      final liste = jsonDecode(brut) as List<dynamic>;
      return liste
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> ecrire(List<Article> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((a) => a.toJson()).toList()),
    );
  }
}

/// État en mémoire de l'historique : la fiche produit enregistre une vue et
/// l'accueil la voit tout de suite au retour, sans relire le disque.
class HistoriqueVisionnageNotifier extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() => HistoriqueVisionnageService.lire();

  Future<void> enregistrer(Article article) async {
    final actuel = state.value ?? const <Article>[];
    if (actuel.isNotEmpty && actuel.first.id == article.id) return;
    final suivant = [
      article,
      ...actuel.where((a) => a.id != article.id),
    ].take(HistoriqueVisionnageService.max).toList();
    state = AsyncData(suivant);
    await HistoriqueVisionnageService.ecrire(suivant);
  }
}

final historiqueVisionnageProvider =
    AsyncNotifierProvider<HistoriqueVisionnageNotifier, List<Article>>(
  HistoriqueVisionnageNotifier.new,
);
