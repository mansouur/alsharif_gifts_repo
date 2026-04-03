import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class SanityService {
  final Dio _dio = Dio();

  Future<dynamic> _query(String groq, [Map<String, String>? params]) async {
    // Build URL manually so $param keys are not percent-encoded by Dio
    var url = '${SanityConfig.baseUrl}?query=${Uri.encodeQueryComponent(groq)}';
    if (params != null) {
      params.forEach((key, value) {
        url += '&\$$key=${Uri.encodeQueryComponent(jsonEncode(value))}';
      });
    }
    try {
      final response = await _dio.get(url);
      return response.data['result'];
    } on DioException catch (e) {
      // ignore: avoid_print
      print('Sanity error: ${e.message} | URL: $url | Response: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    const groq =
        '*[_type == "category"]{_id, title, slug, image, description}';
    final result = await _query(groq);
    if (result == null) return [];
    return (result as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getProducts() async {
    const groq = '''*[_type == "product"]{
      _id, name, slug,
      category->{title, slug},
      images, description, price, onSale, discountPercent,
      saleEndDate, isBestSeller, isNew, inStock, tags
    }''';
    final result = await _query(groq);
    if (result == null) return [];
    return (result as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String slug) async {
    const groq = r'''*[_type == "product" && category->slug.current == $slug]{
      _id, name, slug,
      category->{title, slug},
      images, description, price, onSale, discountPercent,
      saleEndDate, isBestSeller, isNew, inStock, tags
    }''';
    final result = await _query(groq, {'slug': slug});
    if (result == null) return [];
    return (result as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getBestSellers() async {
    const groq = '''*[_type == "product" && isBestSeller == true]{
      _id, name, slug,
      category->{title, slug},
      images, description, price, onSale, discountPercent,
      saleEndDate, isBestSeller, isNew, inStock, tags
    }''';
    final result = await _query(groq);
    if (result == null) return [];
    return (result as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getSaleProducts() async {
    const groq = '''*[_type == "product" && onSale == true]{
      _id, name, slug,
      category->{title, slug},
      images, description, price, onSale, discountPercent,
      saleEndDate, isBestSeller, isNew, inStock, tags
    }''';
    final result = await _query(groq);
    if (result == null) return [];
    return (result as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel?> getProduct(String slug) async {
    const groq = r'''*[_type == "product" && slug.current == $slug][0]{
      _id, name, slug,
      category->{title, slug},
      images, description, price, onSale, discountPercent,
      saleEndDate, isBestSeller, isNew, inStock, tags
    }''';
    final result = await _query(groq, {'slug': slug});
    if (result == null) return null;
    return ProductModel.fromJson(result as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>?> getHomePage() async {
    const groq = r'''*[_type == "homePage"][0]{
      sections[]{
        _type,
        _type == "heroBanner" => {
          title, subtitle, buttonText, buttonLink,
          "imageRef": image.asset._ref
        },
        _type == "featuredProducts" => {
          title,
          "products": products[]->{
            _id, name, slug, images, price, onSale, discountPercent
          }
        },
        _type == "saleBanner" => {
          title, subtitle, buttonText,
          "imageRef": image.asset._ref
        }
      }
    }''';
    final result = await _query(groq);
    if (result == null) return null;
    return result as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> getStoreSettings() async {
    const groq = r'''*[_type == "storeSettings"][0]{
      storeName, storeSubtitle, whatsappNumber,
      workingHours, address, about,
      "logoRef": logo.asset._ref,
      "coverRef": coverImage.asset._ref
    }''';
    final result = await _query(groq);
    if (result == null) return null;
    return result as Map<String, dynamic>;
  }

  Future<List<ProductModel>> searchProducts(String term) async {
    const groq = r'''*[_type == "product" && name match $term]{
      _id, name, slug,
      category->{title, slug},
      images, description, price, onSale, discountPercent,
      saleEndDate, isBestSeller, isNew, inStock, tags
    }''';
    final result = await _query(groq, {'term': '$term*'});
    if (result == null) return [];
    return (result as List).map((e) => ProductModel.fromJson(e)).toList();
  }
}
