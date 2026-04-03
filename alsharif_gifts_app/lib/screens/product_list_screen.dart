import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/sanity_service.dart';
import '../models/product_model.dart';
import '../core/theme.dart';
import '../widgets/product_card_widget.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  final String? categoryTitle;
  final bool saleOnly;

  const ProductListScreen({
    super.key,
    this.categorySlug,
    this.categoryTitle,
    this.saleOnly = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final SanityService _service = SanityService();
  late Future<List<ProductModel>> _products;

  @override
  void initState() {
    super.initState();
    _products = _loadProducts();
  }

  Future<List<ProductModel>> _loadProducts() {
    if (widget.saleOnly) return _service.getSaleProducts();
    if (widget.categorySlug != null) return _service.getProductsByCategory(widget.categorySlug!);
    return _service.getProducts();
  }

  String get _title => widget.saleOnly ? 'العروض' : (widget.categoryTitle ?? 'جميع المنتجات');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: widget.saleOnly
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFFF6B6B)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                      : AppTheme.primaryGradient,
                ),
              ),
              title: Text(_title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
          ),
          FutureBuilder<List<ProductModel>>(
            future: _products,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      childCount: 6,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.saleRed, size: 48),
                        const SizedBox(height: 12),
                        const Text('حدث خطأ في تحميل المنتجات'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() => _products = _loadProducts()),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final products = snapshot.data ?? [];
              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 72, color: AppTheme.primary.withAlpha(100)),
                        const SizedBox(height: 16),
                        const Text('لا توجد منتجات',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: products[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(slug: products[index].slug),
                        ),
                      ),
                    ),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
