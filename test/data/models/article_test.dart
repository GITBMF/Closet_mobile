import 'package:closet/data/models/article.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Article — stockage local', () {
    test('les photos survivent à un aller-retour toJson / fromJson', () {
      final origine = Article.fromApi({
        'id': 'p1',
        'title': 'Trench beige classique',
        'price': 265000,
        'status': 'available',
        'image_url': 'https://cdn.exemple.test/couverture.jpg',
        'images': ['https://cdn.exemple.test/dos.jpg'],
      });
      expect(origine.imageUrls, hasLength(2));

      // Ce que la sélection écrit sur l'appareil, puis relit au lancement.
      final relu = Article.fromJson(origine.toJson());

      expect(relu.imageUrls, origine.imageUrls);
      expect(relu.imageUrls.first, 'https://cdn.exemple.test/couverture.jpg');
    });

    test('une photo présente à la fois en couverture et en liste est unique', () {
      final article = Article.fromApi({
        'id': 'p2',
        'title': 'Sac',
        'image_url': 'https://cdn.exemple.test/a.jpg',
        'images': ['https://cdn.exemple.test/a.jpg'],
      });
      final relu = Article.fromJson(article.toJson());

      expect(relu.imageUrls, ['https://cdn.exemple.test/a.jpg']);
    });
  });
}
