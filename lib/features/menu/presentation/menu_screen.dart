import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../menu/domain/category.dart';
import '../../menu/domain/product.dart';
import 'product_detail_sheet.dart';
import '../../../shared/providers/global_providers.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _selectedCategoryId = MockData.categories.first.id;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      final matchesCategory = product.categoryId == _selectedCategoryId;
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_searchQuery.isNotEmpty) {
        return matchesSearch; // Search overrides category for ease of discovery
      }
      return matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.value ?? MockData.products;
    final filteredProducts = _getFilteredProducts(products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pluffy Menu'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Box Padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search delicious soufflés, coffee, pastries...',
              prefixIcon: Icons.search,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Horizontal Category Tabs
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: MockData.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = MockData.categories[index];
                final isSelected = _selectedCategoryId == category.id && _searchQuery.isEmpty;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                      _searchQuery = ''; // Clear search when switching tabs
                      _searchController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? AppColors.white : AppColors.textMain,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Catalog Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Search Results'
                      : MockData.categories.firstWhere((c) => c.id == _selectedCategoryId).name,
                  style: AppTextStyles.h2,
                ),
                Text(
                  '${filteredProducts.length} items',
                  style: AppTextStyles.bodySecondaryMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Staggered Grid of Products
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: AppColors.border),
                        const SizedBox(height: 16),
                        Text(
                          'No sweet items found',
                          style: AppTextStyles.h3,
                        ),
                        Text(
                          'Try searching for another keyword or tab',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () => ProductDetailSheet.show(context, product),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Mock Image Area with Rating
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.cardBg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.border.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.restaurant,
                                          size: 40,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    
                                    // Rating Tag
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, size: 10, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${product.rating}',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textMain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    // Seasonal tag if applicable
                                    if (product.isSeasonal)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'SEASONAL',
                                            style: AppTextStyles.badgeText.copyWith(fontSize: 8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Product details
                              Text(
                                product.name,
                                style: AppTextStyles.h3.copyWith(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                product.description,
                                style: AppTextStyles.bodySecondary.copyWith(fontSize: 10, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              
                              // Price and add button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatPrice(product.basePrice),
                                    style: AppTextStyles.priceRegular,
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
