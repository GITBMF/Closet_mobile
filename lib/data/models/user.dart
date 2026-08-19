class ClosetUser {
  final String firstName;
  final String lastName;
  final String email;
  final String? token;
  final String? avatarPath;

  ClosetUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.token,
    this.avatarPath,
  });

  factory ClosetUser.fromJson(Map<String, dynamic> json) {
    final fullName = (json['full_name'] ?? json['fullName']) as String?;
    final firstName = (json['first_name'] ?? json['firstName']) as String?;
    final lastName = (json['last_name'] ?? json['lastName']) as String?;

    String parsedFirstName = '';
    String parsedLastName = '';

    if (firstName != null && firstName.isNotEmpty) {
      parsedFirstName = firstName;
      parsedLastName = lastName ?? '';
    } else if (fullName != null && fullName.isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      parsedFirstName = parts.first;
      parsedLastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return ClosetUser(
      firstName: parsedFirstName,
      lastName: parsedLastName,
      email: (json['email'] ?? '') as String,
      token: (json['token'] ?? json['access_token']) as String?,
      avatarPath: json['avatar_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (token != null) 'token': token,
      if (avatarPath != null) 'avatar_path': avatarPath,
    };
  }

  ClosetUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? token,
    String? avatarPath,
  }) {
    return ClosetUser(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      token: token ?? this.token,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
