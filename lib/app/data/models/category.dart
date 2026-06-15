class Category {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final bool isSpecial;
  final String? specialColor;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.isSpecial = false,
    this.specialColor = '#E91E63',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isSpecial: json['is_special'] as bool? ?? false,
      specialColor: json['special_color'] as String? ?? '#E91E63',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_special': isSpecial,
      'special_color': specialColor,
    };
  }

  String get cleanDescription {
    if (description == null) return '';
    final parts = description!.split('||');
    return parts[0].trim();
  }

  String? get categoryImageUrl {
    if (description == null) return null;
    final parts = description!.split('||');
    if (parts.length > 1) {
      final url = parts[1].trim();
      return url.isNotEmpty ? url : null;
    }
    return null;
  }
}
