import '../api/api_json.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final String brand;
  final String size;
  final String material;
  final String condition;
  final double price;
  final List<String> imageUrls;
  final bool isFeatured;
  final String universe;
  final bool isSoldOut;
  final bool isWishlisted;
  final String? story;
  final String? houseId;
  final String? universeId;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.brand,
    required this.size,
    required this.material,
    required this.condition,
    required this.price,
    required this.imageUrls,
    this.isFeatured = false,
    this.universe = '',
    this.isSoldOut = false,
    this.isWishlisted = false,
    this.story,
    this.houseId,
    this.universeId,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article.fromApi(json);
  }

  /// `PieceSummary` / `PieceDetail` du backend.
  factory Article.fromApi(
    Map<String, dynamic> json, {
    String? nomMaison,
    String? nomUnivers,
  }) {
    final images = chainesDe(json['images']);
    final couverture = chaineDe(json['image_url']);
    final urls = <String>[
      if (couverture.isNotEmpty) couverture,
      ...images.where((u) => u != couverture),
    ];
    for (final media in objetsDe(json['media'])) {
      final url = chaineDe(media['url']);
      if (url.isNotEmpty && !urls.contains(url)) urls.add(url);
    }

    final statut = chaineDe(json['status']);
    final conditionApi = chaineDe(json['condition']);
    final titre = chaineDe(json['title']);
    final marque = nomMaison ??
        chaineDe(json['brand'], chaineDe(json['house']));

    return Article(
      id: chaineDe(json['id']),
      title: titre,
      description: chaineDe(json['description'], chaineDe(json['story'])),
      brand: marque.isNotEmpty ? marque : _marqueDepuisTitre(titre),
      size: chaineDe(json['size_label'], chaineDe(json['size'])),
      material: chaineDe(json['material']),
      condition: _libelleEtat(conditionApi),
      price: montantDe(json['price']),
      imageUrls: urls,
      isFeatured: booleenDe(json['isFeatured']),
      universe: nomUnivers ?? chaineDe(json['universe']),
      isSoldOut: statut == 'sold' || statut == 'reserved' || statut == 'withdrawn',
      isWishlisted: booleenDe(json['in_wishlist']),
      story: json['story'] as String?,
      houseId: json['house_id'] as String?,
      universeId: json['universe_id'] as String?,
    );
  }

  /// Quand le backend n'a pas de maison (`house_id` nul), le premier mot
  /// du titre (« Nike Baskets ») tient lieu de marque.
  static String _marqueDepuisTitre(String titre) {
    final mot = titre.trim().split(RegExp(r'\s+')).firstOrNull ?? '';
    return mot;
  }

  static String _libelleEtat(String brut) {
    return switch (brut) {
      'new' => 'Neuf',
      'very_good' => 'Très bon état',
      'good' => 'Bon état',
      'excellent' => 'Excellent',
      _ => brut.isEmpty ? '' : brut,
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'brand': brand,
        'size': size,
        'material': material,
        'condition': condition,
        'price': price,
        'imageUrls': imageUrls,
        'isFeatured': isFeatured,
        'universe': universe,
        'isSoldOut': isSoldOut,
        'isWishlisted': isWishlisted,
        'story': story,
        'house_id': houseId,
        'universe_id': universeId,
      };

  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? brand,
    String? size,
    String? material,
    String? condition,
    double? price,
    List<String>? imageUrls,
    bool? isFeatured,
    String? universe,
    bool? isSoldOut,
    bool? isWishlisted,
    String? story,
    String? houseId,
    String? universeId,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      material: material ?? this.material,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      isFeatured: isFeatured ?? this.isFeatured,
      universe: universe ?? this.universe,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      story: story ?? this.story,
      houseId: houseId ?? this.houseId,
      universeId: universeId ?? this.universeId,
    );
  }
}

class Maison {
  const Maison({required this.id, required this.nom});

  final String id;
  final String nom;

  factory Maison.fromJson(Map<String, dynamic> json) => Maison(
        id: chaineDe(json['id']),
        nom: chaineDe(json['name']),
      );
}

class Univers {
  const Univers({required this.id, required this.nom});

  final String id;
  final String nom;

  factory Univers.fromJson(Map<String, dynamic> json) => Univers(
        id: chaineDe(json['id']),
        nom: chaineDe(json['name']),
      );
}
