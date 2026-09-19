/// Format de date JJ/MM/AAAA — jamais abrégé (ni jour, ni mois), quelle que
/// soit la langue de l'appli : préférence explicite, indépendante de la
/// locale d'affichage des textes.
String formatDateJourMoisAnnee(DateTime d) {
  final jj = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$jj/$mm/${d.year}';
}

/// JJ/MM/AAAA HH:mm — heure complète (24 h), jamais abrégée.
String formatDateCommande(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${formatDateJourMoisAnnee(d)} $hh:$mm';
}
