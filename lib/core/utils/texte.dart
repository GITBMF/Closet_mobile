/// Met la première lettre en majuscule (les accents sont gérés par Dart).
String avecMajuscule(String texte) {
  final t = texte.trimLeft();
  if (t.isEmpty) return texte;
  return t[0].toUpperCase() + t.substring(1);
}
