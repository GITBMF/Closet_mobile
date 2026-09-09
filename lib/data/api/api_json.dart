// Helpers de lecture JSON : le backend ClosET sérialise souvent les montants
// en chaîne (`"38500.00"`) et accepte `null` sur beaucoup de champs.

double montantDe(dynamic valeur) {
  if (valeur == null) return 0;
  if (valeur is num) return valeur.toDouble();
  return double.tryParse(valeur.toString()) ?? 0;
}

int entierDe(dynamic valeur, [int defaut = 0]) {
  if (valeur is int) return valeur;
  if (valeur is num) return valeur.toInt();
  return int.tryParse(valeur?.toString() ?? '') ?? defaut;
}

String chaineDe(dynamic valeur, [String defaut = '']) {
  if (valeur == null) return defaut;
  final texte = valeur.toString().trim();
  return texte.isEmpty ? defaut : texte;
}

bool booleenDe(dynamic valeur, [bool defaut = false]) {
  if (valeur is bool) return valeur;
  return defaut;
}

DateTime? dateDe(dynamic valeur) {
  if (valeur == null) return null;
  return DateTime.tryParse(valeur.toString());
}

Map<String, dynamic> objetDe(dynamic valeur) {
  if (valeur is Map<String, dynamic>) return valeur;
  if (valeur is Map) return Map<String, dynamic>.from(valeur);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> objetsDe(dynamic valeur) {
  if (valeur is! List) return const [];
  return [
    for (final element in valeur)
      if (element is Map<String, dynamic>)
        element
      else if (element is Map)
        Map<String, dynamic>.from(element),
  ];
}

List<String> chainesDe(dynamic valeur) {
  if (valeur is! List) return const [];
  return [for (final e in valeur) if (e != null) e.toString()];
}

/// Tableau JSON, ou `items` / `results` / `data` d'une page.
List<dynamic> listeDe(dynamic valeur) {
  if (valeur is List) return valeur;
  if (valeur is Map) {
    final items = valeur['items'] ?? valeur['results'] ?? valeur['data'];
    if (items is List) return items;
  }
  return const [];
}
