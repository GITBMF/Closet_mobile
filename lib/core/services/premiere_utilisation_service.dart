import 'package:shared_preferences/shared_preferences.dart';

/// Mémorise si la personne a déjà vu (ou passé) l'accueil de première
/// utilisation, pour ne jamais le rejouer aux lancements suivants sans
/// compte — l'app doit alors ouvrir directement « Mon dressing ».
class PremiereUtilisationService {
  PremiereUtilisationService._();

  static const _cle = 'closet_premiere_utilisation_vue';

  static Future<bool> dejaVue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cle) ?? false;
  }

  static Future<void> marquerVue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cle, true);
  }
}
