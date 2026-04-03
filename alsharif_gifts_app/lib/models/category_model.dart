import '../core/constants.dart';

class CategoryModel {
  final String id;
  final String title;
  final String slug;
  final String? imageUrl;
  final String? description;

  CategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    this.imageUrl,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug']?['current'] ?? '',
      imageUrl: _parseImage(json['image']),
      description: json['description'],
    );
  }

  static String? _parseImage(dynamic image) {
    final ref = image?['asset']?['_ref'] as String?;
    if (ref == null) return null;
    return SanityConfig.imageUrl(ref);
  }
}
