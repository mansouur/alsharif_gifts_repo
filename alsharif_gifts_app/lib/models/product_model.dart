import 'package:intl/intl.dart';
import '../core/constants.dart';

final _fmt = NumberFormat('#,##0', 'en_US');

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? categoryTitle;
  final String? categorySlug;
  final List<String> images;
  final String? description;
  final double price;
  final bool onSale;
  final int? discountPercent;
  final String? saleEndDate;
  final bool isBestSeller;
  final bool isNew;
  final bool inStock;
  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.categoryTitle,
    this.categorySlug,
    required this.images,
    this.description,
    required this.price,
    this.onSale = false,
    this.discountPercent,
    this.saleEndDate,
    this.isBestSeller = false,
    this.isNew = false,
    this.inStock = true,
    this.tags = const [],
  });

  double get finalPrice {
    if (onSale && discountPercent != null && discountPercent! > 0) {
      return price * (1 - discountPercent! / 100);
    }
    return price;
  }

  String get firstImage => images.isNotEmpty ? images.first : '';

  String get formattedPrice => '${_fmt.format(price)} ل.س';
  String get formattedFinalPrice => '${_fmt.format(finalPrice)} ل.س';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug']?['current'] ?? '',
      categoryTitle: json['category']?['title'],
      categorySlug: json['category']?['slug']?['current'],
      images: _parseImages(json['images']),
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      onSale: json['onSale'] ?? false,
      discountPercent: json['discountPercent'],
      saleEndDate: json['saleEndDate'],
      isBestSeller: json['isBestSeller'] ?? false,
      isNew: json['isNew'] ?? false,
      inStock: json['inStock'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];
    return (images as List).map((img) {
      final ref = img['asset']?['_ref'] as String?;
      if (ref == null) return '';
      return SanityConfig.imageUrl(ref);
    }).where((url) => url.isNotEmpty).toList();
  }
}
