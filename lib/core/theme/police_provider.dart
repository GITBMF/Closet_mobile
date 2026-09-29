import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _policeKey = 'closet_taille_police';

/// Taille du texte choisie dans les réglages, appliquée à toute l'application.
enum TaillePolice {
  normale(1),
  grande(1.15),
  tresGrande(1.3);

  const TaillePolice(this.facteur);

  final double facteur;
}

class PoliceNotifier extends Notifier<TaillePolice> {
  @override
  TaillePolice build() {
    _charger();
    return TaillePolice.normale;
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final nom = prefs.getString(_policeKey);
    for (final t in TaillePolice.values) {
      if (t.name == nom) state = t;
    }
  }

  Future<void> choisir(TaillePolice taille) async {
    state = taille;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_policeKey, taille.name);
  }
}

final policeProvider =
    NotifierProvider<PoliceNotifier, TaillePolice>(PoliceNotifier.new);
