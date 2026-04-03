import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/sanity_service.dart';
import '../models/category_model.dart';
import '../core/theme.dart';
import '../widgets/category_card_widget.dart';
import 'product_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final SanityService _service = SanityService();
  late Future<List<CategoryModel>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _service.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التصنيفات')),
      body: FutureBuilder<List<CategoryModel>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.saleRed, size: 48),
                  const SizedBox(height: 12),
                  const Text('حدث خطأ في تحميل التصنيفات'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _categories = _service.getCategories()),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('لا توجد تصنيفات'));
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async =>
                setState(() => _categories = _service.getCategories()),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) =>
                  _buildCategoryGridItem(categories[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGridItem(CategoryModel category) {
    return CategoryCard(
      category: category,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListScreen(
            categorySlug: category.slug,
            categoryTitle: category.title,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
