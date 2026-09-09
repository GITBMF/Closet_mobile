// Formats partagés des formulaires ClosET (e-mail, mot de passe, téléphone).

import 'package:flutter/services.dart';

/// Motif e-mail classique : local@domaine.tld, TLD d’au moins 2 lettres.
final RegExp motifEmail = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
  r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
  r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
);

String? validerEmail(String? valeur, {bool obligatoire = true}) {
  final saisie = (valeur ?? '').trim();
  if (saisie.isEmpty) {
    return obligatoire ? 'Veuillez renseigner votre e-mail.' : null;
  }
  if (saisie.length > 254 || saisie.contains(' ')) {
    return 'Cet e-mail semble incorrect.';
  }
  if (!motifEmail.hasMatch(saisie)) {
    return 'Utilisez une adresse du type nom@domaine.com.';
  }
  return null;
}

/// Connexion : le mot de passe existe déjà — on n’impose que la présence.
/// Inscription : 8 à 128 caractères, une lettre, un chiffre, sans espace.
String? validerMotDePasse(String? valeur, {bool connexion = false}) {
  final saisie = valeur ?? '';
  if (saisie.isEmpty) return 'Indiquez votre mot de passe.';
  if (saisie.length > 128) return '128 caractères maximum.';
  if (connexion) return null;
  if (RegExp(r'\s').hasMatch(saisie)) {
    return 'Le mot de passe ne doit pas contenir d’espaces.';
  }
  if (saisie.length < 8) return '8 caractères minimum.';
  if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(saisie)) {
    return 'Ajoutez au moins une lettre.';
  }
  if (!RegExp(r'\d').hasMatch(saisie)) {
    return 'Ajoutez au moins un chiffre.';
  }
  return null;
}

/// Règles affichées sous le champ mot de passe (inscription).
class EtatMotDePasse {
  const EtatMotDePasse({
    required this.longueur,
    required this.lettre,
    required this.chiffre,
    required this.sansEspace,
  });

  factory EtatMotDePasse.de(String saisie) {
    return EtatMotDePasse(
      longueur: saisie.length >= 8 && saisie.length <= 128,
      lettre: RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(saisie),
      chiffre: RegExp(r'\d').hasMatch(saisie),
      sansEspace: saisie.isNotEmpty && !RegExp(r'\s').hasMatch(saisie),
    );
  }

  final bool longueur;
  final bool lettre;
  final bool chiffre;
  final bool sansEspace;

  bool get complet => longueur && lettre && chiffre && sansEspace;
}

/// Identifiant « e-mail ou téléphone » : l’API de connexion n’accepte que
/// l’e-mail. Un numéro bien formé reçoit un message dédié.
String? validerIdentifiantConnexion(String? valeur) {
  final saisie = (valeur ?? '').trim();
  if (saisie.isEmpty) return 'Veuillez renseigner votre e-mail.';
  if (saisie.contains('@')) return validerEmail(saisie);
  final chiffres = saisie.replaceAll(RegExp(r'\D'), '');
  if (chiffres.length >= 8) {
    return 'La connexion se fait avec l’e-mail du compte, pas le téléphone.';
  }
  return 'Utilisez l’e-mail du compte (nom@domaine.com).';
}

/// Première lettre de chaque mot en majuscule (prénom).
class FormateurPrenom extends TextInputFormatter {
  const FormateurPrenom();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final formate = newValue.text.splitMapJoin(
      RegExp(r'(\s+)'),
      onNonMatch: (mot) {
        if (mot.isEmpty) return mot;
        return mot[0].toUpperCase() +
            (mot.length > 1 ? mot.substring(1).toLowerCase() : '');
      },
    );
    return TextEditingValue(
      text: formate,
      selection: TextSelection.collapsed(offset: formate.length),
    );
  }
}

/// Nom de famille entièrement en majuscules.
class FormateurNom extends TextInputFormatter {
  const FormateurNom();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formate = newValue.text.toUpperCase();
    return TextEditingValue(
      text: formate,
      selection: TextSelection.collapsed(offset: formate.length),
    );
  }
}
