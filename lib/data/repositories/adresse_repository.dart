import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adresse.dart';
import 'auth_repository.dart';

final adresseRepositoryProvider = Provider<AdresseRepository>((ref) {
  return AdresseRepository(ref);
});

final mesAdressesProvider = FutureProvider<List<Adresse>>((ref) {
  return ref.watch(adresseRepositoryProvider).getMesAdresses();
});

/// Adresses conservées localement : l'API n'expose pas encore
/// `GET/POST /me/addresses`. Ce n'est pas un jeu simulé — la liste part vide
/// et ne contient que ce que la cliente enregistre sur cet appareil.
class AdresseRepository {
  AdresseRepository(this._ref);

  final Ref _ref;

  static const _cle = 'closet_adresses_v1';

  String get _cleUtilisateur {
    final id = _ref.read(currentUserProvider)?.id ?? 'invite';
    return '${_cle}_$id';
  }

  Future<List<Adresse>> getMesAdresses() async {
    final prefs = await SharedPreferences.getInstance();
    final brut = prefs.getString(_cleUtilisateur);
    if (brut == null || brut.isEmpty) return const [];
    try {
      final liste = jsonDecode(brut) as List<dynamic>;
      return [
        for (final e in liste)
          if (e is Map<String, dynamic>) Adresse.fromJson(e),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _sauver(List<Adresse> adresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cleUtilisateur,
      jsonEncode([for (final a in adresses) a.toJson()]),
    );
  }

  Future<Adresse> enregistrer(Adresse adresse) async {
    final adresses = [...await getMesAdresses()];

    if (adresse.parDefaut) {
      for (var i = 0; i < adresses.length; i++) {
        if (adresses[i].id != adresse.id && adresses[i].parDefaut) {
          adresses[i] = adresses[i].copyWith(parDefaut: false);
        }
      }
    }

    final index = adresses.indexWhere((a) => a.id == adresse.id);
    if (index == -1) {
      adresses.add(adresse);
    } else {
      adresses[index] = adresse;
    }

    if (adresses.length == 1 && !adresses.first.parDefaut) {
      adresses[0] = adresses.first.copyWith(parDefaut: true);
    }

    await _sauver(adresses);
    return adresses.firstWhere((a) => a.id == adresse.id, orElse: () => adresse);
  }

  Future<void> supprimer(String id) async {
    final adresses = [...await getMesAdresses()]..removeWhere((a) => a.id == id);
    if (adresses.isNotEmpty && !adresses.any((a) => a.parDefaut)) {
      adresses[0] = adresses.first.copyWith(parDefaut: true);
    }
    await _sauver(adresses);
  }

  Future<String> prochainId() async {
    final adresses = await getMesAdresses();
    final pris = {for (final a in adresses) int.tryParse(a.id) ?? 0};
    var i = 1;
    while (pris.contains(i)) {
      i++;
    }
    return i.toString();
  }
}
