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
  final String universe; // Robes, Vestes, Sacs, Escarpins, Accessoires
  final bool isSoldOut;
  final bool isWishlisted;

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
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      brand: json['brand'] as String,
      size: json['size'] as String,
      material: json['material'] as String? ?? '',
      condition: json['condition'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from((json['imageUrls'] as List<dynamic>?) ?? <dynamic>[]),
      isFeatured: json['isFeatured'] as bool? ?? false,
      universe: json['universe'] as String? ?? '',
      isSoldOut: json['isSoldOut'] as bool? ?? false,
      isWishlisted: json['isWishlisted'] as bool? ?? false,
    );
  }

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
    );
  }
}
