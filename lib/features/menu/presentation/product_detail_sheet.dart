import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/data/cart_repository.dart';
import '../domain/product.dart';

class ProductDetailSheet extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailSheet({
    Key? key,
    required this.product,
  }) : super(key: key);

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ProductDetailSheet(product: product),
        );
      },
    );
  }

  @override
  ConsumerState<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends ConsumerState<ProductDetailSheet> {
  int _quantity = 1;
  String? _selectedSweetness;
  String? _selectedIce;
  String? _selectedTemperature;
  final List<CustomizationAddon> _selectedAddons = [];

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.stock == 0 ? 0 : 1;
    // Pre-select defaults if options are available
    if (widget.product.availableSweetness != null && widget.product.availableSweetness!.isNotEmpty) {
      _selectedSweetness = widget.product.availableSweetness!.contains('100%')
          ? '100%'
          : widget.product.availableSweetness!.first;
    }
    if (widget.product.availableIce != null && widget.product.availableIce!.isNotEmpty) {
      _selectedIce = widget.product.availableIce!.contains('Normal')
          ? 'Normal'
          : widget.product.availableIce!.first;
    }
    if (widget.product.availableTemperature != null && widget.product.availableTemperature!.isNotEmpty) {
      _selectedTemperature = widget.product.availableTemperature!.contains('Iced')
          ? 'Iced'
          : widget.product.availableTemperature!.first;
    }
  }

  double _calculateCurrentPrice() {
    double unitPrice = widget.product.basePrice;
    double addonsPrice = _selectedAddons.fold(0.0, (sum, addon) => sum + addon.price);
    return (unitPrice + addonsPrice) * _quantity;
  }

  void _toggleAddon(CustomizationAddon addon) {
    setState(() {
      if (_selectedAddons.contains(addon)) {
        _selectedAddons.remove(addon);
      } else {
        _selectedAddons.add(addon);
      }
    });
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    }
    return '\$${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final totalPrice = _calculateCurrentPrice();

    return Column(
      children: [
        // Bottom sheet header handle
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Hero Illustration Area
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Name & Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyles.h1.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating}',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              if (product.isSeasonal)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SEASONAL SPECIAL',
                                    style: AppTextStyles.badgeText.copyWith(fontSize: 8),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatPrice(product.basePrice),
                      style: AppTextStyles.priceLarge.copyWith(fontSize: 22),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  product.description,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      product.stock == 0 ? Icons.error_outline : Icons.inventory_2_outlined,
                      size: 16,
                      color: product.stock == 0
                          ? AppColors.primary
                          : product.stock <= 5
                              ? Colors.orange
                              : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.stock == 0
                          ? 'Sold Out - Habis Terjual'
                          : product.stock <= 5
                              ? 'Stok Terbatas: Sisa ${product.stock} pcs!'
                              : 'Stok Tersedia: ${product.stock} pcs',
                      style: AppTextStyles.bodySecondaryMedium.copyWith(
                        color: product.stock == 0
                            ? AppColors.primary
                            : product.stock <= 5
                                ? Colors.orange
                                : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 36),
                
                // 1. TEMPERATURE SECTION
                if (product.availableTemperature != null) ...[
                  Text('Choose Temperature', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Row(
                    children: product.availableTemperature!.map((temp) {
                      final isSelected = _selectedTemperature == temp;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTemperature = temp),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    temp == 'Hot' ? Icons.local_fire_department : Icons.ac_unit,
                                    size: 16,
                                    color: isSelected ? AppColors.white : AppColors.textMain,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    temp,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected ? AppColors.white : AppColors.textMain,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 36),
                ],

                // 2. SWEETNESS LEVEL SECTION
                if (product.availableSweetness != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sweetness Level', style: AppTextStyles.h3),
                      Text(
                        _selectedSweetness ?? '',
                        style: AppTextStyles.bodySecondaryMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: product.availableSweetness!.map((level) {
                      final isSelected = _selectedSweetness == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSweetness = level),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                level,
                                style: AppTextStyles.bodySecondaryMedium.copyWith(
                                  color: isSelected ? AppColors.white : AppColors.textMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 36),
                ],

                // 3. ICE LEVEL SECTION
                if (product.availableIce != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ice Level', style: AppTextStyles.h3),
                      Text(
                        _selectedIce ?? '',
                        style: AppTextStyles.bodySecondaryMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: product.availableIce!.map((ice) {
                      final isSelected = _selectedIce == ice;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIce = ice),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                ice,
                                style: AppTextStyles.bodySecondaryMedium.copyWith(
                                  color: isSelected ? AppColors.white : AppColors.textMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 36),
                ],

                // 4. ADDONS SECTION
                if (product.availableAddons.isNotEmpty) ...[
                  Text('Premium Add-ons', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Column(
                    children: product.availableAddons.map((addon) {
                      final isSelected = _selectedAddons.contains(addon);
                      return GestureDetector(
                        onTap: () => _toggleAddon(addon),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.cardBg : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    addon.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '+${_formatPrice(addon.price)}',
                                style: AppTextStyles.priceRegular.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
        
        // Quantity & Action Button Bottom Panel
        Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 28),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textMain.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16, color: AppColors.textMain),
                      onPressed: product.stock == 0 ? null : () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: AppColors.textMain),
                      onPressed: product.stock == 0 || _quantity >= product.stock ? null : () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Add to Cart button
              Expanded(
                child: CustomButton(
                  text: product.stock == 0
                      ? 'Sold Out - Habis'
                      : 'Add to Cart — ${_formatPrice(totalPrice)}',
                  onPressed: product.stock == 0
                      ? null
                      : () {
                          ref.read(cartProvider.notifier).addItem(
                            product: product,
                            quantity: _quantity,
                            selectedSweetness: _selectedSweetness,
                            selectedIce: _selectedIce,
                            selectedTemperature: _selectedTemperature,
                            selectedAddons: _selectedAddons,
                          );
                          
                          Navigator.pop(context);

                          // Confirmation banner
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.shopping_bag, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Added $_quantity x ${product.name} to Cart!'),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
