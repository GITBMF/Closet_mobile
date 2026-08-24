/// Indicatifs téléphoniques proposés dans le sélecteur (drapeau + recherche).
class IndicateurPays {
  const IndicateurPays({
    required this.iso,
    required this.nom,
    required this.indicatif,
    required this.minChiffres,
    required this.maxChiffres,
  });

  /// Code ISO 3166-1 alpha-2, utilisé pour le drapeau emoji.
  final String iso;
  final String nom;

  /// Chiffres de l’indicatif, sans le `+`.
  final String indicatif;
  final int minChiffres;
  final int maxChiffres;

  String get drapeau {
    final u = iso.toUpperCase();
    return String.fromCharCodes([
      0x1F1E6 + u.codeUnitAt(0) - 0x41,
      0x1F1E6 + u.codeUnitAt(1) - 0x41,
    ]);
  }

  String get libelleCourt => '+$indicatif';

  static const cameroun = IndicateurPays(
    iso: 'CM',
    nom: 'Cameroun',
    indicatif: '237',
    minChiffres: 9,
    maxChiffres: 9,
  );

  static const tous = <IndicateurPays>[
    cameroun,
    IndicateurPays(
      iso: 'CI',
      nom: 'Côte d’Ivoire',
      indicatif: '225',
      minChiffres: 10,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'SN',
      nom: 'Sénégal',
      indicatif: '221',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'TG',
      nom: 'Togo',
      indicatif: '228',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'BJ',
      nom: 'Bénin',
      indicatif: '229',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'BF',
      nom: 'Burkina Faso',
      indicatif: '226',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'ML',
      nom: 'Mali',
      indicatif: '223',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'NE',
      nom: 'Niger',
      indicatif: '227',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'GN',
      nom: 'Guinée',
      indicatif: '224',
      minChiffres: 8,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'GA',
      nom: 'Gabon',
      indicatif: '241',
      minChiffres: 7,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'CG',
      nom: 'Congo',
      indicatif: '242',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'CD',
      nom: 'RD Congo',
      indicatif: '243',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'TD',
      nom: 'Tchad',
      indicatif: '235',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'CF',
      nom: 'Centrafrique',
      indicatif: '236',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'GQ',
      nom: 'Guinée équatoriale',
      indicatif: '240',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'NG',
      nom: 'Nigeria',
      indicatif: '234',
      minChiffres: 10,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'GH',
      nom: 'Ghana',
      indicatif: '233',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'KE',
      nom: 'Kenya',
      indicatif: '254',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'ZA',
      nom: 'Afrique du Sud',
      indicatif: '27',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'MA',
      nom: 'Maroc',
      indicatif: '212',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'TN',
      nom: 'Tunisie',
      indicatif: '216',
      minChiffres: 8,
      maxChiffres: 8,
    ),
    IndicateurPays(
      iso: 'DZ',
      nom: 'Algérie',
      indicatif: '213',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'EG',
      nom: 'Égypte',
      indicatif: '20',
      minChiffres: 10,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'FR',
      nom: 'France',
      indicatif: '33',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'BE',
      nom: 'Belgique',
      indicatif: '32',
      minChiffres: 8,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'CH',
      nom: 'Suisse',
      indicatif: '41',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'CA',
      nom: 'Canada',
      indicatif: '1',
      minChiffres: 10,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'US',
      nom: 'États-Unis',
      indicatif: '1',
      minChiffres: 10,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'GB',
      nom: 'Royaume-Uni',
      indicatif: '44',
      minChiffres: 10,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'DE',
      nom: 'Allemagne',
      indicatif: '49',
      minChiffres: 10,
      maxChiffres: 11,
    ),
    IndicateurPays(
      iso: 'IT',
      nom: 'Italie',
      indicatif: '39',
      minChiffres: 9,
      maxChiffres: 10,
    ),
    IndicateurPays(
      iso: 'ES',
      nom: 'Espagne',
      indicatif: '34',
      minChiffres: 9,
      maxChiffres: 9,
    ),
    IndicateurPays(
      iso: 'PT',
      nom: 'Portugal',
      indicatif: '351',
      minChiffres: 9,
      maxChiffres: 9,
    ),
  ];

  static List<IndicateurPays> rechercher(String requete) {
    final q = _normaliser(requete);
    if (q.isEmpty) {
      return List<IndicateurPays>.from(tous);
    }
    return [
      for (final p in tous)
        if (_normaliser(p.nom).contains(q) ||
            p.iso.toLowerCase().contains(q) ||
            p.indicatif.contains(q) ||
            '+${p.indicatif}'.contains(q))
          p,
    ];
  }

  /// Décompose une saisie (`+237 6 99…`, `00237…`, `237699…`) en pays + national.
  static SaisieTelephone? analyser(String brut) {
    var compact = brut.trim();
    if (compact.isEmpty) return null;
    if (compact.startsWith('00')) compact = '+${compact.substring(2)}';
    final avecPlus = compact.startsWith('+');
    final digits = compact.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    final tries = List<IndicateurPays>.from(tous)
      ..sort((a, b) => b.indicatif.length.compareTo(a.indicatif.length));

    for (final p in tries) {
      if (!digits.startsWith(p.indicatif)) continue;
      final national = digits.substring(p.indicatif.length);
      if (national.isEmpty) continue;
      if (national.length > p.maxChiffres) continue;
      if (avecPlus || national.length >= p.minChiffres) {
        return SaisieTelephone(pays: p, national: national);
      }
    }
    return null;
  }

  static String _normaliser(String s) {
    return s
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ù', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('’', "'")
        .replaceAll("'", '');
  }
}

class SaisieTelephone {
  const SaisieTelephone({required this.pays, required this.national});

  final IndicateurPays pays;
  final String national;
}

String? validerTelephone(
  String? e164, {
  required bool obligatoire,
  String libelle = 'numéro',
}) {
  final saisie = (e164 ?? '').trim();
  if (saisie.isEmpty) {
    return obligatoire ? 'Indiquez un $libelle.' : null;
  }
  final parse = IndicateurPays.analyser(saisie);
  if (parse == null) return 'Ce $libelle semble incorrect.';
  if (parse.national.length < parse.pays.minChiffres) {
    return 'Ce $libelle semble incomplet.';
  }
  return null;
}
