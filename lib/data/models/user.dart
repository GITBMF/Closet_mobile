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

  bool get estSourceur =>
      role == 'sourcer' || role == 'admin';

  factory ClosetUser.fromJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String? ?? json['fullName'] as String?;
    final firstName = json['first_name'] as String? ?? json['firstName'] as String?;
    final lastName = json['last_name'] as String? ?? json['lastName'] as String?;

    var parsedFirstName = '';
    var parsedLastName = '';

    if (firstName != null && firstName.isNotEmpty) {
      parsedFirstName = firstName;
      parsedLastName = lastName ?? '';
    } else if (fullName != null && fullName.isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      parsedFirstName = parts.first;
      parsedLastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return ClosetUser(
      id: (json['id'] ?? '') as String,
      firstName: parsedFirstName,
      lastName: parsedLastName,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? json['telephone'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      role: (json['role'] ?? 'customer') as String,
      token: json['token'] as String? ?? json['access_token'] as String?,
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
