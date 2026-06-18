class Product {
  final String id;
  final String title;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? categoryId;
  final int stock;
  final int soldCount;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.discountPrice,
    this.categoryId,
    required this.stock,
    this.soldCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  double get effectivePrice => discountPrice != null ? discountPrice! : price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  bool get isOutOfStock => stock <= 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse list of image URLs safely from text[] database format
    List<String> urls = [];
    if (json['image_urls'] != null) {
      if (json['image_urls'] is List) {
        urls = (json['image_urls'] as List).map((e) => e.toString()).toList();
      } else if (json['image_urls'] is String) {
        // Handle case where Postgres returns it as string representation: e.g. "{url1,url2}"
        final str = json['image_urls'] as String;
        if (str.startsWith('{') && str.endsWith('}')) {
          urls = str.substring(1, str.length - 1).split(',').where((s) => s.isNotEmpty).toList();
        } else {
          urls = [str];
        }
      }
    }

    return Product(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num? ?? 0.0).toDouble(),
      discountPrice: json['discount_price'] != null ? (json['discount_price'] as num).toDouble() : null,
      categoryId: json['category_id'] as String?,
      stock: (json['stock'] as num? ?? 0).toInt(),
      soldCount: (json['sold_count'] as num? ?? 0).toInt(),
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      reviewCount: (json['review_count'] as num? ?? 0).toInt(),
      imageUrls: urls,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'category_id': categoryId,
      'stock': stock,
      'sold_count': soldCount,
      'rating': rating,
      'review_count': reviewCount,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
