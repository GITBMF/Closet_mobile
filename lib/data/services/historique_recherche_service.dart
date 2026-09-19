import 'package:shared_preferences/shared_preferences.dart';

/// Recherches récentes, pour le bloc « Recherches populaires ».
class HistoriqueRechercheService {
  static const _key = 'closet_recherches_recentes_v1';
  static const max = 8;

  static Future<List<String>> lire() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  static Future<List<String>> enregistrer(String brut) async {
    final q = brut.trim();
    if (q.length < 2) return lire();
    final actuel = await lire();
    final suivant = [
      q,
      ...actuel.where((e) => e.toLowerCase() != q.toLowerCase()),
    ].take(max).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, suivant);
    return suivant;
  }
}
