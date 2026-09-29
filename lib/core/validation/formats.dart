// Formats partagés des formulaires ClosET (e-mail, mot de passe, téléphone).

import 'package:flutter/services.dart';

import '../l10n/closet_l10n.dart';

/// Motif e-mail classique : local@domaine.tld, TLD d’au moins 2 lettres.
final RegExp motifEmail = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
  r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
  r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
);

String? validerEmail(String? valeur,
    {bool obligatoire = true, ClosetL10n? l10n}) {
  final mots = l10n ?? ClosetL10n.fr;
  final saisie = (valeur ?? '').trim();
  if (saisie.isEmpty) {
    if (!obligatoire) return null;
    return mots.renseignerEmail;
  }
  if (saisie.length > 254 || saisie.contains(' ')) {
    return mots.emailIncorrect;
  }
  if (!motifEmail.hasMatch(saisie)) {
    return mots.emailFormatAttendu;
  }
  return null;
}

/// Connexion : le mot de passe existe déjà — on n’impose que la présence.
/// Inscription : 8 à 128 caractères, une lettre, un chiffre, sans espace.
String? validerMotDePasse(String? valeur,
    {bool connexion = false, ClosetL10n? l10n}) {
  final mots = l10n ?? ClosetL10n.fr;
  final saisie = valeur ?? '';
  if (saisie.isEmpty) return mots.renseignerMdp;
  if (saisie.length > 128) return mots.max128;
  if (connexion) return null;
  if (RegExp(r'\s').hasMatch(saisie)) return mots.mdpSansEspaces;
  if (saisie.length < 8) return mots.min8Caracteres;
  if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(saisie)) return mots.ajouterLettre;
  if (!RegExp(r'\d').hasMatch(saisie)) return mots.ajouterChiffre;
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
String? validerIdentifiantConnexion(String? valeur, [ClosetL10n? l10n]) {
  final mots = l10n ?? ClosetL10n.fr;
  final saisie = (valeur ?? '').trim();
  if (saisie.isEmpty) return mots.renseignerEmail;
  if (saisie.contains('@')) return validerEmail(saisie, l10n: l10n);
  final chiffres = saisie.replaceAll(RegExp(r'\D'), '');
  if (chiffres.length >= 8) return mots.connexionEmailPasTelephone;
  return mots.utiliserEmailCompte;
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
