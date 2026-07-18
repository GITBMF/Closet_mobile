import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

class CatalogRepository {
  // Données mockées reproduisant fidèlement la maquette Lovable
  Future<List<Article>> getCatalog({String? universe}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final all = _mockArticles;
    if (universe == null || universe == 'Tout l\'univers') return all;
    return all.where((a) => a.universe == universe).toList();
  }

  Future<Article?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _mockArticles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Article> getFeatured() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockArticles.firstWhere((a) => a.isFeatured);
  }

  Future<List<Article>> getNewArrivals() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockArticles.take(4).toList();
  }

  Future<List<Article>> getCoupDeCoeur() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockArticles.skip(2).take(4).toList();
  }

  static final List<Article> _mockArticles = [
    Article(
      id: '1',
      title: 'Robe Élégance Durable',
      description:
          '« Une silhouette épurée signée d\'une maison parisienne de référence. La soie coule le long du corps avec une légèreté absolue — une pièce d\'architecture pour les grandes occasions. »',
      brand: 'Sandro',
      size: '38',
      material: 'Soie',
      condition: 'Excellent',
      price: 38500,
      imageUrls: [
        'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=600&q=80',
        'https://images.unsplash.com/photo-1566479179817-0b57cef62b6a?w=600&q=80',
      ],
      isFeatured: true,
      universe: 'Robes',
    ),
    Article(
      id: '2',
      title: 'Sac Cuir Camel',
      description:
          '« Un sac porté épaule en cuir pleine fleur d\'une douceur exceptionnelle. La teinte caramel dorée s\'harmonise avec toutes les tenues, du casual au plus habillé. »',
      brand: 'Sézane',
      size: 'Unique',
      material: 'Cuir pleine fleur',
      condition: 'Très bon',
      price: 31000,
      imageUrls: [
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600&q=80',
      ],
      universe: 'Sacs',
      isWishlisted: true,
    ),
    Article(
      id: '3',
      title: 'Veste Tweed Crème',
      description:
          '« Une coupe crop signée d\'une maison parisienne réputée pour son sens du geste couture. Un tweed écru rehaussé de fils dorés — une pièce d\'architecture pour le vestiaire de jour. »',
      brand: 'Maje',
      size: '36',
      material: 'Laine · Tweed',
      condition: 'Excellent',
      price: 24500,
      imageUrls: [
        'https://images.unsplash.com/photo-1591369822096-ffd140ec948f?w=600&q=80',
        'https://images.unsplash.com/photo-1614093302611-8efc6688b504?w=600&q=80',
      ],
      universe: 'Vestes',
      isWishlisted: true,
    ),
    Article(
      id: '4',
      title: 'Blouse Ivoire Fluide',
      description:
          '« Une blouse de soie ivoire à col en V qui glisse sur le buste avec une élégance naturelle. La coupe loose apporte une liberté de mouvement rare dans la mode de luxe. »',
      brand: 'Rue Sereine',
      size: 'S',
      material: 'Soie',
      condition: 'Très bon',
      price: 18500,
      imageUrls: [
        'https://images.unsplash.com/photo-1594938298603-c8148c4b4e2f?w=600&q=80',
      ],
      universe: 'Robes',
      isWishlisted: true,
    ),
    Article(
      id: '5',
      title: 'Robe Plissée Sable',
      description:
          '« Une robe midi plissée en viscose au tombé impeccable. La teinte sable lumineux capte la lumière à chaque mouvement, faisant de cette pièce une présence à elle seule. »',
      brand: 'Massimo Dutti',
      size: '38',
      material: 'Viscose',
      condition: 'Très bon',
      price: 22000,
      imageUrls: [
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
        'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=80',
      ],
      universe: 'Robes',
    ),
    Article(
      id: '6',
      title: 'Robe Portefeuille',
      description:
          '« La robe portefeuille iconique de Maje dans un coloris ivoire intemporel. Une pièce déjà adoptée par notre communauté — vous pouvez vous inscrire pour être alertée si elle revient. »',
      brand: 'Maje',
      size: '38',
      material: 'Soie',
      condition: 'Excellent',
      price: 29000,
      imageUrls: [
        'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600&q=80',
      ],
      universe: 'Robes',
      isSoldOut: true,
    ),
  ];
}
