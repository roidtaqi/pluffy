import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../menu/domain/category.dart';
import '../../menu/domain/product.dart';
import 'product_detail_sheet.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _menuScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  final GlobalKey _menuViewportKey = GlobalKey();
  late final Map<String, GlobalKey> _sectionKeys;
  late final Map<String, GlobalKey> _categoryTabKeys;

  String _selectedCategoryId = MockData.categories.first.id;
  String _searchQuery = '';
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _sectionKeys = {
      for (final category in MockData.categories) category.id: GlobalKey(),
    };
    _categoryTabKeys = {
      for (final category in MockData.categories) category.id: GlobalKey(),
    };
    _menuScrollController.addListener(_syncCategoryWithScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _menuScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  List<MenuCategory> _availableCategories(List<Product> products) {
    return MockData.categories.where((category) {
      return products.any((product) => product.categoryId == category.id);
    }).toList();
  }

  List<Product> _searchResults(List<Product> products) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  void _syncCategoryWithScroll() {
    if (_isProgrammaticScroll || _searchQuery.isNotEmpty || !mounted) return;

    final viewportBox =
        _menuViewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;

    String? visibleCategoryId;
    for (final category in MockData.categories) {
      final sectionBox =
          _sectionKeys[category.id]?.currentContext?.findRenderObject()
              as RenderBox?;
      if (sectionBox == null) continue;

      final offset = sectionBox.localToGlobal(
        Offset.zero,
        ancestor: viewportBox,
      );
      if (offset.dy <= 28) {
        visibleCategoryId = category.id;
      } else {
        break;
      }
    }

    if (_menuScrollController.position.extentAfter < 48) {
      final availableCategories = _availableCategories(
        ref.read(productsProvider).value ?? MockData.products,
      );
      if (availableCategories.isNotEmpty) {
        visibleCategoryId = availableCategories.last.id;
      }
    }

    if (visibleCategoryId == null || visibleCategoryId == _selectedCategoryId) {
      return;
    }

    setState(() => _selectedCategoryId = visibleCategoryId!);
    _keepActiveTabVisible(visibleCategoryId);
  }

  void _keepActiveTabVisible(String categoryId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabContext = _categoryTabKeys[categoryId]?.currentContext;
      if (!mounted || tabContext == null) return;

      Scrollable.ensureVisible(
        tabContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    });
  }

  Future<void> _scrollToCategory(String categoryId) async {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _searchController.clear();
        _searchQuery = '';
        _selectedCategoryId = categoryId;
      });
      await WidgetsBinding.instance.endOfFrame;
    } else {
      setState(() => _selectedCategoryId = categoryId);
    }

    final sectionContext = _sectionKeys[categoryId]?.currentContext;
    if (sectionContext == null || !sectionContext.mounted) return;

    _isProgrammaticScroll = true;
    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0,
    );
    _isProgrammaticScroll = false;
    _keepActiveTabVisible(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.value ?? MockData.products;
    final categories = _availableCategories(products);
    final searchResults = _searchResults(products);

    if (categories.isNotEmpty &&
        !categories.any((category) => category.id == _selectedCategoryId)) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Pluffy'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Cari soufflé, kopi, pastry...',
              prefixIcon: Icons.search,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    _selectedCategoryId == category.id && _searchQuery.isEmpty;

                return GestureDetector(
                  key: _categoryTabKeys[category.id],
                  onTap: () => _scrollToCategory(category.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
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
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _SearchResults(products: searchResults)
                : Container(
                    key: _menuViewportKey,
                    child: SingleChildScrollView(
                      controller: _menuScrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          for (final category in categories)
                            _CategorySection(
                              key: _sectionKeys[category.id],
                              category: category,
                              products: products
                                  .where(
                                    (product) =>
                                        product.categoryId == category.id,
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final MenuCategory category;
  final List<Product> products;

  const _CategorySection({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${category.emoji}  ${category.name}',
                style: AppTextStyles.h2,
              ),
              Text(
                '${products.length} item',
                style: AppTextStyles.bodySecondaryMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _ProductCard(product: products[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Product> products;

  const _SearchResults({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text('Menu belum ditemukan', style: AppTextStyles.h3),
            Text(
              'Coba kata kunci atau kategori lain.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hasil Pencarian', style: AppTextStyles.h2),
              Text(
                '${products.length} item',
                style: AppTextStyles.bodySecondaryMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final category = MockData.categories.firstWhere(
      (category) => category.id == product.categoryId,
      orElse: () => MockData.categories.first,
    );

    return GestureDetector(
      onTap: () => ProductDetailSheet.show(context, product),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
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
                  if (product.isSeasonal)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'MUSIMAN',
                          style: AppTextStyles.badgeText.copyWith(fontSize: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              style: AppTextStyles.h3.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              product.description,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 10,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
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
  }
}
