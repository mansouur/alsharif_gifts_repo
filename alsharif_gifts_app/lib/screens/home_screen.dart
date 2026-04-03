import 'package:flutter/material.dart';
import '../services/sanity_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../widgets/hero_banner_widget.dart';
import '../widgets/sale_banner_widget.dart';
import '../widgets/featured_products_widget.dart';
import '../widgets/category_card_widget.dart';
import '../core/theme.dart';
import '../core/app_config.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SanityService _service = SanityService();
  late Future<Map<String, dynamic>> _homeData;

  @override
  void initState() {
    super.initState();
    _homeData = _loadHomeData();
  }

  Future<Map<String, dynamic>> _loadHomeData() async {
    final results = await Future.wait([
      _service.getHomePage(),
      _service.getCategories(),
      _service.getBestSellers(),
    ]);
    return {
      'homePage': results[0],
      'categories': results[1],
      'bestSellers': results[2],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeData,
        builder: (context, snapshot) {
          return NestedScrollView(
            headerSliverBuilder: (_, _) => [_buildSliverAppBar()],
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : snapshot.hasError
                    ? _buildError()
                    : _buildBody(snapshot.data!),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppConfig.storeName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            AppConfig.storeSubtitle,
            style: TextStyle(
                color: Colors.white.withAlpha(200), fontSize: 11),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.saleRed.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off, color: AppTheme.saleRed, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('تعذر الاتصال بالخادم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _homeData = _loadHomeData()),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    final homePage = data['homePage'] as Map<String, dynamic>?;
    final categories = data['categories'] as List<CategoryModel>;
    final bestSellers = data['bestSellers'] as List<ProductModel>;
    final sections = homePage?['sections'] as List? ?? [];

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => setState(() => _homeData = _loadHomeData()),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ..._buildSections(sections),
          if (categories.isNotEmpty) _buildCategoriesRow(categories),
          if (bestSellers.isNotEmpty)
            FeaturedProductsWidget(
              title: 'الأكثر مبيعاً',
              products: bestSellers,
              onProductTap: _openProduct,
            ),
          _buildAllProductsBanner(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildSections(List sections) {
    final widgets = <Widget>[];
    final heroBanners = <Map<String, dynamic>>[];

    for (final section in sections) {
      if (section == null) continue;
      if (section['_type'] == 'heroBanner') {
        heroBanners.add(section as Map<String, dynamic>);
      }
    }

    if (heroBanners.isNotEmpty) {
      widgets.add(HeroBannerWidget(
        banners: heroBanners,
        onBannerTap: (banner) {
          final link = banner['buttonLink'] as String?;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductListScreen(saleOnly: link == 'sale'),
            ),
          );
        },
      ));
    }

    for (final section in sections) {
      if (section == null) continue;
      final type = section['_type'];
      if (type == 'featuredProducts') {
        final raw = section['products'] as List? ?? [];
        final products = raw
            .where((e) => e != null)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (products.isNotEmpty) {
          widgets.add(FeaturedProductsWidget(
            title: section['title'] ?? 'منتجات مميزة',
            products: products,
            onProductTap: _openProduct,
          ));
        }
      } else if (type == 'saleBanner') {
        widgets.add(SaleBannerWidget(
          banner: section as Map<String, dynamic>,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductListScreen(saleOnly: true)),
          ),
        ));
      }
    }

    return widgets;
  }

  Widget _buildCategoriesRow(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('التصنيفات', onMore: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListScreen()),
        )),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, i) => CategoryCard(
              category: categories[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    categorySlug: categories[i].slug,
                    categoryTitle: categories[i].title,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllProductsBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('تصفح جميع المنتجات',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('اكتشف كل ما لدينا',
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grid_view, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: const Text('عرض الكل',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary)),
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
    );
  }

  void _openProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: product.slug)),
    );
  }
}
