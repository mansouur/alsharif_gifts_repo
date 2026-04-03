import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../services/sanity_service.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../core/theme.dart';
import '../core/formatters.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final SanityService _service = SanityService();
  late Future<ProductModel?> _product;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _product = _service.getProduct(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ProductModel?>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('لم يتم العثور على المنتج')),
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(ProductModel product) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageCarousel(product),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                if (product.categoryTitle != null)
                  Text(
                    product.categoryTitle!,
                    style: const TextStyle(color: AppTheme.secondary, fontSize: 14),
                  ),
                const SizedBox(height: 12),
                _buildPriceRow(product),
                const SizedBox(height: 12),
                _buildStockBadge(product),
                const SizedBox(height: 16),
                if (product.description != null && product.description!.isNotEmpty) ...[
                  const Text(
                    'الوصف',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                    textAlign: TextAlign.right,
                  ),
                ],
                if (product.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: product.tags
                        .map((tag) => Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppTheme.primary.withAlpha(26),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),

                // عداد + زر السلة مرتبطان بـ CartProvider مباشرة
                if (product.inStock)
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final inCart = cart.contains(product.id);
                      final qty = inCart
                          ? cart.items
                              .firstWhere((i) => i.product.id == product.id)
                              .quantity
                          : 0;

                      if (inCart) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('الكمية',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(
                                  'المجموع: ${formatPrice(product.finalPrice * qty)}',
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // زيادة
                                _counterBtn(
                                  icon: Icons.add,
                                  color: AppTheme.primary,
                                  onTap: () => cart.increment(product.id),
                                ),
                                const SizedBox(width: 12),
                                Text('$qty',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                // نقصان أو حذف
                                _counterBtn(
                                  icon: qty == 1
                                      ? Icons.delete_outline
                                      : Icons.remove,
                                  color:
                                      qty == 1 ? Colors.red : AppTheme.secondary,
                                  onTap: () => cart.decrement(product.id),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      // لم يُضف بعد
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cart.add(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('أُضيف: ${product.name}'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart,
                              color: Colors.white),
                          label: const Text('أضف إلى السلة',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _counterBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildImageCarousel(ProductModel product) {
    if (product.images.isEmpty) {
      return Container(
        color: AppTheme.primary.withAlpha(51),
        child: const Icon(Icons.image_not_supported, size: 80, color: AppTheme.primary),
      );
    }
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 320,
            viewportFraction: 1.0,
            autoPlay: product.images.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => setState(() => _currentImage = index),
          ),
          items: product.images.map((url) {
            return CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(
                color: AppTheme.primary.withAlpha(51),
                child: const Icon(Icons.image_not_supported),
              ),
            );
          }).toList(),
        ),
        if (product.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: product.images.asMap().entries.map((entry) {
                return Container(
                  width: _currentImage == entry.key ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImage == entry.key
                        ? Colors.white
                        : Colors.white.withAlpha(128),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow(ProductModel product) {
    if (product.onSale && product.discountPercent != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            product.formattedPrice,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                decoration: TextDecoration.lineThrough),
          ),
          const SizedBox(width: 8),
          Text(
            product.formattedFinalPrice,
            style: const TextStyle(
                color: AppTheme.saleRed, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.saleRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${product.discountPercent}% خصم',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
    return Text(
      product.formattedPrice,
      style: const TextStyle(
          color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.bold),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildStockBadge(ProductModel product) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: product.inStock
              ? Colors.green.withAlpha(26)
              : Colors.grey.withAlpha(51),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: product.inStock ? Colors.green : Colors.grey),
        ),
        child: Text(
          product.inStock ? 'متوفر' : 'غير متوفر',
          style: TextStyle(
            color: product.inStock ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
