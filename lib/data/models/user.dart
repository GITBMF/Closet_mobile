class ClosetUser {
  final String firstName;
  final String lastName;
  final String email;
  final String? token;

  ClosetUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.token,
  });

  factory ClosetUser.fromJson(Map<String, dynamic> json) {
    return ClosetUser(
      firstName: (json['first_name'] ?? json['firstName'] ?? '') as String,
      lastName: (json['last_name'] ?? json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      token: (json['token'] ?? json['access_token']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (token != null) 'token': token,
    };
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
