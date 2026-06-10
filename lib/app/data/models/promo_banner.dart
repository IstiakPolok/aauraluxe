class PromoBanner {
  final String id;
  final String imageUrl;
  final String? categoryId;
  final DateTime createdAt;

  PromoBanner({
    required this.id,
    required this.imageUrl,
    this.categoryId,
    required this.createdAt,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'image_url': imageUrl,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
