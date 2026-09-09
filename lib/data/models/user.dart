class ClosetUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String city;
  final String role;
  final String? token;

  ClosetUser({
    this.id = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone = '',
    this.city = '',
    this.role = 'customer',
    this.token,
  });

  ClosetUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? city,
    String? role,
    String? token,
  }) {
    return ClosetUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  String get nomComplet => '$firstName $lastName'.trim();

  /// Rôle JWT `sourcer` / `admin` (casse et variante FR `sourceur` ignorées).
  bool get estSourceur {
    final r = role.trim().toLowerCase();
    return r == 'sourcer' || r == 'sourceur' || r == 'admin';
  }

  factory ClosetUser.fromJson(Map<String, dynamic> json) {
    final fullName = _texte(json['full_name'] ?? json['fullName']);
    final firstName = _texte(json['first_name'] ?? json['firstName']);
    final lastName = _texte(json['last_name'] ?? json['lastName']);

    var parsedFirstName = '';
    var parsedLastName = '';

    if (firstName.isNotEmpty) {
      parsedFirstName = firstName;
      parsedLastName = lastName;
    } else if (fullName.isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      parsedFirstName = parts.first;
      parsedLastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return ClosetUser(
      id: _texte(json['id']),
      firstName: parsedFirstName,
      lastName: parsedLastName,
      email: _texte(json['email']),
      phone: _texte(json['phone'] ?? json['telephone']),
      city: _texte(json['city']),
      role: _roleDepuis(json),
      token: _texteOuNul(json['token'] ?? json['access_token']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': nomComplet,
      'email': email,
      'phone': phone,
      'city': city,
      'role': role,
      if (token != null) 'token': token,
    };
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}

String _texte(dynamic valeur, [String defaut = '']) {
  if (valeur == null) return defaut;
  final texte = valeur.toString().trim();
  return texte.isEmpty ? defaut : texte;
}

/// Lit `role`, un objet `{ name }` ou le premier élément de `roles`.
String _roleDepuis(Map<String, dynamic> json) {
  final brut = json['role'] ?? json['user_role'];
  final depuisChamp = _texteRole(brut);
  if (depuisChamp.isNotEmpty) return depuisChamp;

  final roles = json['roles'];
  if (roles is List && roles.isNotEmpty) {
    final premier = _texteRole(roles.first);
    if (premier.isNotEmpty) return premier;
  }
  return 'customer';
}

String _texteRole(dynamic valeur) {
  if (valeur == null) return '';
  if (valeur is Map) {
    return _texte(
      valeur['name'] ?? valeur['value'] ?? valeur['slug'] ?? valeur['role'],
    ).toLowerCase();
  }
  return _texte(valeur).toLowerCase();
}

String? _texteOuNul(dynamic valeur) {
  final texte = _texte(valeur);
  return texte.isEmpty ? null : texte;
}
