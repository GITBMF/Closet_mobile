import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../bff_client/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  final Ref _ref;
  final BffClient _client;

  // Local embedded native database of users for the MVP
  static final List<ClosetUser> _localDb = [
    ClosetUser(firstName: 'Closet', lastName: 'Premium', email: 'user@closet.com'),
  ];
  static final Map<String, String> _localPasswords = {
    'user@closet.com': 'closet123',
  };

  AuthRepository(this._ref, this._client) {
    // Referencing properties to resolve compiler warnings
    _ref.toString();
    _client.toString();
  }

  Future<ClosetUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    // Local embedded database simulation
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final lowerEmail = email.toLowerCase().trim();
    if (_localPasswords.containsKey(lowerEmail)) {
      throw Exception('Un utilisateur avec cet e-mail existe déjà.');
    }
    final user = ClosetUser(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: lowerEmail,
      token: 'mock-jwt-token-12345',
    );
    _saveToLocal(user, password);
    return user;
  }

  Future<ClosetUser> logIn({
    required String email,
    required String password,
  }) async {
    // Local embedded database simulation
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final lowerEmail = email.toLowerCase().trim();
    final index = _localDb.indexWhere((u) => u.email.toLowerCase() == lowerEmail);
    if (index == -1 || _localPasswords[lowerEmail] != password) {
      throw Exception('Identifiants de connexion invalides.');
    }
    return _localDb[index];
  }

  void _saveToLocal(ClosetUser user, String password) {
    final lowerEmail = user.email.toLowerCase().trim();
    if (!_localDb.any((u) => u.email.toLowerCase() == lowerEmail)) {
      _localDb.add(user);
      _localPasswords[lowerEmail] = password;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(bffClientProvider);
  return AuthRepository(ref, client);
});

final currentUserProvider = StateProvider<ClosetUser?>((ref) => null);
