import 'package:closet/data/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClosetUser.estSourceur', () {
    ClosetUser user({String role = 'customer'}) => ClosetUser(
          firstName: 'Amina',
          lastName: 'A.',
          email: 'a@b.cm',
          role: role,
        );

    test('reconnaît sourcer, sourceur et admin, casse ignorée', () {
      expect(user(role: 'sourcer').estSourceur, isTrue);
      expect(user(role: 'Sourcer').estSourceur, isTrue);
      expect(user(role: 'sourceur').estSourceur, isTrue);
      expect(user(role: 'admin').estSourceur, isTrue);
      expect(user().estSourceur, isFalse);
    });
  });

  group('ClosetUser.fromJson rôle', () {
    test('lit une chaîne, un objet ou la liste roles', () {
      expect(ClosetUser.fromJson({'role': 'sourcer'}).role, 'sourcer');
      expect(ClosetUser.fromJson({'role': 'Sourcer'}).role, 'sourcer');
      expect(
        ClosetUser.fromJson({
          'role': {'name': 'sourcer'},
        }).role,
        'sourcer',
      );
      expect(
        ClosetUser.fromJson({
          'roles': ['sourcer'],
        }).role,
        'sourcer',
      );
    });
  });
}
