import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../core/theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildImage()),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  _buildPrice(),
                  if (!product.inStock)
                    const Text('غير متوفر',
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            if (product.inStock)
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final inCart = cart.contains(product.id);
                  if (inCart) {
                    final qty = cart.items
                        .firstWhere((i) => i.product.id == product.id)
                        .quantity;
                    return _buildCounter(context, cart, qty);
                  }
                  return _buildAddButton(context, cart);
                },
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SizedBox(
        width: double.infinity,
        height: 32,
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
          icon: const Icon(Icons.add_shopping_cart, size: 14, color: Colors.white),
          label: const Text('أضف', style: TextStyle(fontSize: 11, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(BuildContext context, CartProvider cart, int qty) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.secondary.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.secondary.withAlpha(77)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الزيادة
            GestureDetector(
              onTap: () => cart.increment(product.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
            // العداد
            Text(
              '$qty',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.secondary),
            ),
            // حذف أو نقصان
            GestureDetector(
              onTap: () => cart.decrement(product.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: qty == 1 ? Colors.red : AppTheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  qty == 1 ? Icons.delete_outline : Icons.remove,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: product.firstImage.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.firstImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.image_not_supported),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),
        if (product.onSale && product.discountPercent != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.saleRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${product.discountPercent}% خصم',
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (product.isBestSeller)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'الأكثر مبيعاً',
                style: TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrice() {
    if (product.onSale && product.discountPercent != null) {
      return Row(
        children: [
          Text(
            product.formattedFinalPrice,
            style: const TextStyle(
                color: AppTheme.saleRed, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            product.price.toStringAsFixed(0),
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                decoration: TextDecoration.lineThrough),
          ),
        ],
      );
    }
    return Text(
      product.formattedPrice,
      style: const TextStyle(
          color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}
