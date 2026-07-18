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
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      isFeatured: json['isFeatured'] as bool? ?? false,
      universe: json['universe'] as String? ?? '',
      isSoldOut: json['isSoldOut'] as bool? ?? false,
      isWishlisted: json['isWishlisted'] as bool? ?? false,
    );
  }
}
