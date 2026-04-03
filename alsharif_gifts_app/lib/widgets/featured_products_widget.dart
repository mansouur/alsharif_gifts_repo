import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/theme.dart';
import 'product_card_widget.dart';

class FeaturedProductsWidget extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final Function(ProductModel) onProductTap;

  const FeaturedProductsWidget({
    super.key,
    required this.title,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) => SizedBox(
              width: 170,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ProductCard(
                  product: products[index],
                  onTap: () => onProductTap(products[index]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
