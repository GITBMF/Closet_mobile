import 'package:flutter/foundation.dart';

/// Nature d'une adresse enregistrée — détermine son icône dans la liste.
enum TypeAdresse { maison, bureau, appartement, autre }

/// Une adresse de livraison — maquette `26:1588`.
@immutable
class Adresse {
  const Adresse({
    required this.id,
    required this.libelle,
    required this.ligne,
    required this.type,
    this.parDefaut = false,
  });

  final String id;

  /// Nom donné par la cliente (« Maison », « Bureau »…).
  final String libelle;

  /// Adresse complète sur une ligne.
  final String ligne;

  final TypeAdresse type;

  /// Adresse retenue par défaut au moment de commander.
  final bool parDefaut;

  Adresse copyWith({
    String? id,
    String? libelle,
    String? ligne,
    TypeAdresse? type,
    bool? parDefaut,
  }) {
    return Adresse(
      id: id ?? this.id,
      libelle: libelle ?? this.libelle,
      ligne: ligne ?? this.ligne,
      type: type ?? this.type,
      parDefaut: parDefaut ?? this.parDefaut,
    );
  }

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      id: json['id'] as String,
      libelle: json['libelle'] as String? ?? '',
      ligne: json['ligne'] as String? ?? '',
      type: TypeAdresse.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TypeAdresse.autre,
      ),
      parDefaut: json['parDefaut'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'libelle': libelle,
        'ligne': ligne,
        'type': type.name,
        'parDefaut': parDefaut,
      };
}
