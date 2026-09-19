import 'package:closet/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('payloadInscriptionCliente', () {
    test('envoie exactement email, password, full_name et phone compact', () {
      expect(
        payloadInscriptionCliente(
          email: '  Aicha.N@Closet.cm ',
          password: 'Secret123',
          firstName: 'Aïcha',
          lastName: 'N.',
          phone: '+237 6 99 00 00 00',
        ),
        {
          'email': 'aicha.n@closet.cm',
          'password': 'Secret123',
          'full_name': 'Aïcha N.',
          'phone': '+237699000000',
        },
      );
    });

    test('omet phone et city s’ils sont vides', () {
      final payload = payloadInscriptionCliente(
        email: 'a@b.cm',
        password: 'x',
        firstName: 'Ada',
        lastName: 'Lovelace',
      );
      expect(payload.containsKey('phone'), isFalse);
      expect(payload.containsKey('city'), isFalse);
      expect(payload['full_name'], 'Ada Lovelace');
    });

    test('compacte les espaces du nom', () {
      expect(
        payloadInscriptionCliente(
          email: 'a@b.cm',
          password: 'x',
          firstName: '  Marie  ',
          lastName: '  Claire  ',
        )['full_name'],
        'Marie Claire',
      );
    });
  });
}
