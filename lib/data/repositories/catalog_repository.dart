import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

class CatalogRepository {
  Future<List<Article>> getCatalog({String? universe}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final all = _mockArticles;
    if (universe == null || universe == 'Tout l\'univers') return all;
    if (universe == 'Chaussures') {
      return all
          .where((a) {
            final u = a.universe.toLowerCase();
            return u == 'chaussures' || u == 'escarpins';
          })
          .toList();
    }
    if (universe == 'Nouveautés') {
      return all.where((a) => !a.isSoldOut).toList();
    }
    return all
        .where((a) => a.universe.toLowerCase() == universe.toLowerCase())
        .toList();
  }

  Future<Article?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _mockArticles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Article> getFeatured() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockArticles.firstWhere((a) => a.isFeatured, orElse: () => _mockArticles.first);
  }

  Future<List<Article>> getNewArrivals() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockArticles.where((a) => !a.isSoldOut).take(6).toList();
  }

  Future<List<Article>> getCoupDeCoeur() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockArticles.where((a) => !a.isSoldOut).skip(6).take(6).toList();
  }

  // List of all categories including new ones
  static const List<String> categories = [
    'Robes',
    'Vestes',
    'Sacs',
    'Escarpins',
    'Accessoires',
    'Bijoux',
    'Maille',
    'Manteaux',
  ];

  static final List<Article> _mockArticles = _generateArticles();

  static List<Article> _generateArticles() {
    final list = <Article>[
      // Original 6 articles for consistency
      Article(
        id: '1',
        title: 'Robe Élégance Durable',
        description: '« Une silhouette épurée signée d\'une maison parisienne de référence. La soie coule le long du corps avec une légèreté absolue — une pièce d\'architecture pour les grandes occasions. »',
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
        description: '« Un sac porté épaule en cuir pleine fleur d\'une douceur exceptionnelle. La teinte caramel dorée s\'harmonise avec toutes les tenues, du casual au plus habillé. »',
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
        description: '« Une coupe crop signée d\'une maison parisienne réputée pour son sens du geste couture. Un tweed écru rehaussé de fils dorés — une pièce d\'architecture pour le vestiaire de jour. »',
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
        description: '« Une blouse de soie ivoire à col en V qui glisse sur le buste avec une élégance naturelle. La coupe loose apporte une liberté de mouvement rare dans la mode de luxe. »',
        brand: 'Rue Sereine',
        size: 'S',
        material: 'Soie',
        condition: 'Très bon',
        price: 18500,
        imageUrls: [
          'https://images.unsplash.com/photo-1594938298603-c8148c4b4e2f?w=600&q=80',
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
        ],
        universe: 'Robes',
        isWishlisted: true,
      ),
      Article(
        id: '5',
        title: 'Robe Plissée Sable',
        description: '« Une robe midi plissée en viscose au tombé impeccable. La teinte sable lumineux capte la lumière à chaque mouvement, faisant de cette pièce une présence à elle seule. »',
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
        description: '« La robe portefeuille iconique de Maje dans un coloris ivoire intemporel. Une pièce déjà adoptée par notre communauté — vous pouvez vous inscrire pour être alertée si elle revient. »',
        brand: 'Maje',
        size: '38',
        material: 'Soie',
        condition: 'Excellent',
        price: 29000,
        imageUrls: [
          'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600&q=80',
          'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=600&q=80',
        ],
        universe: 'Robes',
        isSoldOut: true,
      ),
    ];

    // Data maps to dynamically generate additional 50 unique high-quality pieces
    final Map<String, List<Map<String, dynamic>>> categoryTemplates = {
      'Robes': [
        {'title': 'Robe Midi Fleurie', 'brand': 'Sézane', 'material': 'Coton bio', 'price': 19500.0, 'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&q=80'},
        {'title': 'Robe de Soirée Noire', 'brand': 'Sandro', 'material': 'Velours', 'price': 42000.0, 'image': 'https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=600&q=80'},
        {'title': 'Robe Cocktail Rouge', 'brand': 'Maje', 'material': 'Crêpe de soie', 'price': 35000.0, 'image': 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80'},
        {'title': 'Robe d\'Été Lin Blanc', 'brand': 'Jacquemus', 'material': 'Lin', 'price': 48000.0, 'image': 'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=600&q=80'},
        {'title': 'Robe Plissée Soleil', 'brand': 'Claudie Pierlot', 'material': 'Satin', 'price': 27500.0, 'image': 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=80'},
        {'title': 'Robe Chemise Rayée', 'brand': 'Polo Ralph Lauren', 'material': 'Coton Oxford', 'price': 22500.0, 'image': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80'},
      ],
      'Vestes': [
        {'title': 'Veste Blazer Croisé', 'brand': 'Sandro', 'material': 'Laine froide', 'price': 34000.0, 'image': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80'},
        {'title': 'Veste en Jean Brut', 'brand': 'APC', 'material': 'Coton denim', 'price': 17500.0, 'image': 'https://images.unsplash.com/photo-1544441893-675973e31985?w=600&q=80'},
        {'title': 'Perfecto Cuir Noir', 'brand': 'Zadig & Voltaire', 'material': 'Cuir d\'agneau', 'price': 65000.0, 'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80'},
        {'title': 'Veste Matelassée Kaki', 'brand': 'Barbour', 'material': 'Toile cirée', 'price': 38000.0, 'image': 'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?w=600&q=80'},
        {'title': 'Veste Velours Côtelé', 'brand': 'Maje', 'material': 'Velours', 'price': 26000.0, 'image': 'https://images.unsplash.com/photo-1578932750294-f5075e85f44a?w=600&q=80'},
        {'title': 'Blazer Oversize Gris', 'brand': 'Anine Bing', 'material': 'Laine vierge', 'price': 49000.0, 'image': 'https://images.unsplash.com/photo-1618220179428-22790b461013?w=600&q=80'},
      ],
      'Sacs': [
        {'title': 'Sac Chiquito Noir', 'brand': 'Jacquemus', 'material': 'Cuir lisse', 'price': 58000.0, 'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80'},
        {'title': 'Sac Seau Raffia', 'brand': 'Loewe', 'material': 'Raphia et Cuir', 'price': 89000.0, 'image': 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=600&q=80'},
        {'title': 'Sac Cabas Toile', 'brand': 'Marc Jacobs', 'material': 'Coton', 'price': 24000.0, 'image': 'https://images.unsplash.com/photo-1566150905478-db857f17f6b7?w=600&q=80'},
        {'title': 'Sac Bandoulière Croco', 'brand': 'Saint Laurent', 'material': 'Cuir embossé', 'price': 145000.0, 'image': 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&q=80'},
        {'title': 'Sac à Main Vintage', 'brand': 'Gucci', 'material': 'Toile suprême', 'price': 98000.0, 'image': 'https://images.unsplash.com/photo-1598532163257-ae3c6b2524b6?w=600&q=80'},
        {'title': 'Sac Besace Daim', 'brand': 'Isabel Marant', 'material': 'Cuir de chèvre daim', 'price': 42000.0, 'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80'},
      ],
      'Escarpins': [
        {'title': 'Escarpins Vernis Noirs', 'brand': 'Christian Louboutin', 'material': 'Cuir verni', 'price': 120000.0, 'image': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80'},
        {'title': 'Sandales à Talon Or', 'brand': 'Jimmy Choo', 'material': 'Cuir métallisé', 'price': 95000.0, 'image': 'https://images.unsplash.com/photo-1596702994290-9f490a6818a9?w=600&q=80'},
        {'title': 'Escarpins Rockstud', 'brand': 'Valentino', 'material': 'Cuir et clous', 'price': 87000.0, 'image': 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?w=600&q=80'},
        {'title': 'Mules Slingback', 'brand': 'Dior', 'material': 'Toile brodée', 'price': 110000.0, 'image': 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600&q=80'},
        {'title': 'Escarpins Brides Croisées', 'brand': 'Prada', 'material': 'Saffiano', 'price': 78000.0, 'image': 'https://images.unsplash.com/photo-1512374382149-4337c89718a7?w=600&q=80'},
        {'title': 'Bottines Talon Cuir', 'brand': 'Sézane', 'material': 'Cuir lisse', 'price': 34000.0, 'image': 'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600&q=80'},
      ],
      'Accessoires': [
        {'title': 'Ceinture Double G', 'brand': 'Gucci', 'material': 'Cuir pleine fleur', 'price': 28000.0, 'image': 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600&q=80'},
        {'title': 'Carré de Soie Cheval', 'brand': 'Hermès', 'material': 'Soie de Lyon', 'price': 45000.0, 'image': 'https://images.unsplash.com/photo-1589156280159-27698a70f29e?w=600&q=80'},
        {'title': 'Lunettes de Soleil Cat-eye', 'brand': 'Celine', 'material': 'Acétate', 'price': 21000.0, 'image': 'https://images.unsplash.com/photo-1590548784297-2e6592233cca?w=600&q=80'},
        {'title': 'Chapeau de Paille Fringed', 'brand': 'Jacquemus', 'material': 'Paille naturelle', 'price': 18500.0, 'image': 'https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?w=600&q=80'},
        {'title': 'Portefeuille Zippé Saffiano', 'brand': 'Prada', 'material': 'Cuir Saffiano', 'price': 32000.0, 'image': 'https://images.unsplash.com/photo-1611085583191-a3b1a1a39ac2?w=600&q=80'},
        {'title': 'Écharpe en Cachemire Écossaise', 'brand': 'Burberry', 'material': 'Cachemire d\'Écosse', 'price': 39000.0, 'image': 'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=600&q=80'},
      ],
      'Bijoux': [
        {'title': 'Bracelet Clou Doré', 'brand': 'Cartier', 'material': 'Or jaune 18k', 'price': 280000.0, 'image': 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&q=80'},
        {'title': 'Collier Trèfle Nacre', 'brand': 'Van Cleef & Arpels', 'material': 'Nacre & Or jaune', 'price': 220000.0, 'image': 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600&q=80'},
        {'title': 'Bague de Fiançaille Diamant', 'brand': 'Tiffany & Co', 'material': 'Platine & Diamant', 'price': 450000.0, 'image': 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&q=80'},
        {'title': 'Boucles d\'oreilles Perles', 'brand': 'Chanel', 'material': 'Perles de culture', 'price': 85000.0, 'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600&q=80'},
        {'title': 'Jonc Diamants Messika', 'brand': 'Messika', 'material': 'Or blanc & Diamants', 'price': 195000.0, 'image': 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=600&q=80'},
        {'title': 'Collier Chaîne Maillons', 'brand': 'APM Monaco', 'material': 'Argent 925 doré', 'price': 29000.0, 'image': 'https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=600&q=80'},
      ],
      'Maille': [
        {'title': 'Pull Cachemire Écru', 'brand': 'Sézane', 'material': 'Cachemire', 'price': 19000.0, 'image': 'https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?w=600&q=80'},
        {'title': 'Gilet Duveteux Mohair', 'brand': 'Maje', 'material': 'Mohair & Laine', 'price': 24000.0, 'image': 'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=600&q=80'},
        {'title': 'Pull Torsadé Laine', 'brand': 'Sandro', 'material': 'Laine mérinos', 'price': 21000.0, 'image': 'https://images.unsplash.com/photo-1574164904299-3a102b110380?w=600&q=80'},
        {'title': 'Col Roulé Fines Côtes', 'brand': 'Loro Piana', 'material': 'Cachemire ultrafin', 'price': 89000.0, 'image': 'https://images.unsplash.com/photo-1608060434411-0c3fa9049e7b?w=600&q=80'},
        {'title': 'Cardigan Vintage Brodé', 'brand': 'Claudie Pierlot', 'material': 'Laine d\'alpaga', 'price': 26000.0, 'image': 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600&q=80'},
        {'title': 'Pull Col V Lâche', 'brand': 'Acne Studios', 'material': 'Alpaga mélangé', 'price': 34000.0, 'image': 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600&q=80'},
      ],
      'Manteaux': [
        {'title': 'Manteau Ceinturé Camel', 'brand': 'Max Mara', 'material': 'Laine & Cachemire', 'price': 148000.0, 'image': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600&q=80'},
        {'title': 'Trench Iconique Beige', 'brand': 'Burberry', 'material': 'Gabardine de coton', 'price': 125000.0, 'image': 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=600&q=80'},
        {'title': 'Manteau Droit Noir', 'brand': 'Sandro', 'material': 'Laine mélangée', 'price': 48000.0, 'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80'},
        {'title': 'Caban Marine Lourd', 'brand': 'Maje', 'material': 'Laine vierge', 'price': 39000.0, 'image': 'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=600&q=80'},
        {'title': 'Manteau Long Oversize', 'brand': 'Ganni', 'material': 'Laine bouclée', 'price': 42000.0, 'image': 'https://images.unsplash.com/photo-1495385794356-15371f54b791?w=600&q=80'},
        {'title': 'Doudoune Plumes Ceinturée', 'brand': 'Moncler', 'material': 'Duvet d\'oie', 'price': 185000.0, 'image': 'https://images.unsplash.com/photo-1520975954732-35dd22299614?w=600&q=80'},
      ],
    };

    final sizes = ['34', '36', '38', '40', '42', 'S', 'M', 'L', 'Unique'];
    final conditions = ['Excellent', 'Très bon', 'Neuf avec étiquette'];
    final descriptions = [
      '« Une coupe impeccable pensée pour s\'intégrer parfaitement dans votre garde-robe. Une texture d\'une douceur remarquable qui sublime la silhouette avec discrétion. »',
      '« Une pièce signature d\'une grande élégance. Le choix des matières premières de premier ordre assure un confort sans égal et un tombé parfait tout au long de la journée. »',
      '« L\'expression ultime du savoir-faire traditionnel d\'une grande maison. Un classique revisité qui apportera immédiatement une touche de sophistication à votre look. »',
      '« Une pépite seconde main soigneusement sélectionnée par notre atelier d\'experts. Finitions soignées, détails raffinés, un véritable incontournable intemporel. »',
    ];

    int idCounter = 7;

    // Generate 50+ items by looping over universes
    for (final category in categories) {
      final templates = categoryTemplates[category] ?? [];
      for (int i = 0; i < 7; i++) {
        final template = templates[i % templates.length];
        
        final size = category == 'Sacs' || category == 'Bijoux' || (category == 'Accessoires' && i % 2 == 0)
            ? 'Unique'
            : sizes[i % sizes.length];

        final condition = conditions[(i + idCounter) % conditions.length];
        final desc = descriptions[i % descriptions.length];
        final title = template['title'] as String;
        final brand = template['brand'] as String;
        final material = template['material'] as String;
        final price = template['price'] as double;
        final image = template['image'] as String;

        // Tweak values slightly based on index to create variety
        final modifiedPrice = price + ((i % 3) - 1) * 1500;
        final isSoldOut = (idCounter % 15 == 0);
        final isWishlisted = (idCounter % 9 == 0);

        list.add(Article(
          id: idCounter.toString(),
          title: '$title ${['Studio', 'Édition Limite', 'Chic', 'Signature', 'Collection'][i % 5]}',
          description: desc,
          brand: brand,
          size: size,
          material: material,
          condition: condition,
          price: modifiedPrice,
          imageUrls: [
            image,
            _getSecondaryImage(category, i),
          ],
          isFeatured: false,
          universe: category,
          isSoldOut: isSoldOut,
          isWishlisted: isWishlisted,
        ));

        idCounter++;
      }
    }

    return list;
  }

  static String _getSecondaryImage(String category, int index) {
    final images = _categoryImages[category] ?? _fallbackImages;
    return images[(index + 1) % images.length];
  }

  static final Map<String, List<String>> _categoryImages = {
    'Robes': [
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&q=80',
      'https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=600&q=80',
      'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80',
      'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=600&q=80',
      'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=80',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
    ],
    'Vestes': [
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80',
      'https://images.unsplash.com/photo-1544441893-675973e31985?w=600&q=80',
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80',
      'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?w=600&q=80',
      'https://images.unsplash.com/photo-1578932750294-f5075e85f44a?w=600&q=80',
      'https://images.unsplash.com/photo-1618220179428-22790b461013?w=600&q=80',
    ],
    'Sacs': [
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80',
      'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=600&q=80',
      'https://images.unsplash.com/photo-1566150905478-db857f17f6b7?w=600&q=80',
      'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&q=80',
      'https://images.unsplash.com/photo-1598532163257-ae3c6b2524b6?w=600&q=80',
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
    ],
    'Escarpins': [
      'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80',
      'https://images.unsplash.com/photo-1596702994290-9f490a6818a9?w=600&q=80',
      'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?w=600&q=80',
      'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600&q=80',
      'https://images.unsplash.com/photo-1512374382149-4337c89718a7?w=600&q=80',
      'https://images.unsplash.com/photo-1605733513597-a8f8341084e6?w=600&q=80',
    ],
    'Accessoires': [
      'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=600&q=80',
      'https://images.unsplash.com/photo-1589156280159-27698a70f29e?w=600&q=80',
      'https://images.unsplash.com/photo-1590548784297-2e6592233cca?w=600&q=80',
      'https://images.unsplash.com/photo-1601121141461-9d6647bca1ed?w=600&q=80',
      'https://images.unsplash.com/photo-1611085583191-a3b1a1a39ac2?w=600&q=80',
      'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=600&q=80',
    ],
    'Bijoux': [
      'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&q=80',
      'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600&q=80',
      'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&q=80',
      'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600&q=80',
      'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=600&q=80',
      'https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=600&q=80',
    ],
    'Maille': [
      'https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?w=600&q=80',
      'https://images.unsplash.com/photo-1584273143981-41c073dfe8f8?w=600&q=80',
      'https://images.unsplash.com/photo-1574164904299-3a102b110380?w=600&q=80',
      'https://images.unsplash.com/photo-1608060434411-0c3fa9049e7b?w=600&q=80',
      'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600&q=80',
      'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600&q=80',
    ],
    'Manteaux': [
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600&q=80',
      'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=600&q=80',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80',
      'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=600&q=80',
      'https://images.unsplash.com/photo-1495385794356-15371f54b791?w=600&q=80',
      'https://images.unsplash.com/photo-1520975954732-35dd22299614?w=600&q=80',
    ],
  };

  static final List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=600&q=80',
    'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
  ];
}
