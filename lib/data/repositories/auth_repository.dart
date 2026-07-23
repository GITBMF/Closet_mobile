import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user.dart';
import '../bff_client/api_client.dart';

class AuthRepository {
  final Ref _ref;
  final BffClient _client;

  // Local embedded native database of users for the MVP
  static final List<ClosetUser> _localDb = [
    ClosetUser(firstName: 'Ahmed', lastName: 'Jalil', email: 'user@closet.com'),
  ];
  static final Map<String, String> _localPasswords = {
    'user@closet.com': 'password',
  };

  AuthRepository(this._ref, this._client);

  Future<ClosetUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    // 1. Try hitting the backend BFF
    try {
      final response = await _client.dio.post('/auth/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = ClosetUser.fromJson(response.data as Map<String, dynamic>);
        _saveToLocal(user, password);
        return user;
      }
    } catch (_) {
      // Backend not running/unreachable, fallback to local embedded database
    }

    // 2. Local fallback
    await Future.delayed(const Duration(milliseconds: 800));
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
    // 1. Try hitting the backend BFF
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        return ClosetUser.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Backend not running/unreachable, fallback to local embedded database
    }

    // 2. Local fallback
    await Future.delayed(const Duration(milliseconds: 800));
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
