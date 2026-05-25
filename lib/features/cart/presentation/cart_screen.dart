import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../cart/data/cart_repository.dart';
import '../../checkout/presentation/payment_sheet.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _voucherController = TextEditingController();
  String _voucherError = '';

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher(WidgetRef ref) {
    setState(() {
      _voucherError = '';
    });
    
    final code = _voucherController.text;
    if (code.isEmpty) return;

    final success = ref.read(cartProvider.notifier).applyVoucher(code);
    if (success) {
      _voucherController.clear();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Voucher successfully applied!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setState(() {
        _voucherError = 'Invalid code. Try PLUFFY15, SOUFFLE50, or SAKURA20';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final activeOutlet = ref.watch(activeOutletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clear();
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is empty',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse our premium soufflés and customize them to your exact liking!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      text: 'Explore Menu',
                      width: 180,
                      onPressed: () {
                        context.go('/menu');
                      },
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Top outlet pickup indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withOpacity(0.4),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Picking up from: ',
                        style: AppTextStyles.bodySecondaryMedium.copyWith(fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          activeOutlet.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final product = item.product;

                      // Build options subtext
                      List<String> options = [];
                      if (item.selectedTemperature != null) options.add(item.selectedTemperature!);
                      if (item.selectedSweetness != null) options.add('Sweet: ${item.selectedSweetness}');
                      if (item.selectedIce != null) options.add('Ice: ${item.selectedIce}');
                      for (var addon in item.selectedAddons) {
                        options.add(addon.name);
                      }
                      final optionsText = options.join(' • ');

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Thumbnail
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
                              ),
                              child: const Center(
                                child: Icon(Icons.restaurant, size: 24, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            // Item Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppTextStyles.h3.copyWith(fontSize: 14),
                                  ),
                                  if (optionsText.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      optionsText,
                                      style: AppTextStyles.bodySecondary.copyWith(
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  
                                  // Price & Quantity Selector Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatPrice(item.totalPrice),
                                        style: AppTextStyles.priceRegular.copyWith(fontSize: 15),
                                      ),
                                      
                                      // Quantity selector
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBg,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.border, width: 0.8),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                ref.read(cartProvider.notifier).updateQuantity(
                                                      item.id,
                                                      item.quantity - 1,
                                                    );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                child: Icon(Icons.remove, size: 14, color: AppColors.textMain),
                                              ),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                ref.read(cartProvider.notifier).updateQuantity(
                                                      item.id,
                                                      item.quantity + 1,
                                                    );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                child: Icon(Icons.add, size: 14, color: AppColors.textMain),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Billing Summary Panel
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: const Border(
                      top: BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textMain.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Voucher Input Area
                          if (cart.appliedVoucherCode == null) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _voucherController,
                                    hintText: 'Enter Promo Code (e.g. PLUFFY15)',
                                    onChanged: (_) {
                                      if (_voucherError.isNotEmpty) {
                                        setState(() => _voucherError = '');
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () => _applyVoucher(ref),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('Apply'),
                                  ),
                                ),
                              ],
                            ),
                            if (_voucherError.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text(
                                  _voucherError,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    color: AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            // Applied code tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.success, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified, color: AppColors.success, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Code "${cart.appliedVoucherCode}" Applied!',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(cartProvider.notifier).removeVoucher();
                                    },
                                    child: Text(
                                      'Remove',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          
                          // 2. Billing Breakdown Table
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: AppTextStyles.bodySecondaryMedium),
                              Text(formatPrice(cart.subtotal), style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          if (cart.discountAmount > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Promo Discount',
                                  style: AppTextStyles.bodySecondaryMedium.copyWith(color: AppColors.success),
                                ),
                                Text(
                                  '-${formatPrice(cart.discountAmount)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Service Tax (10%)', style: AppTextStyles.bodySecondaryMedium),
                              Text(formatPrice(cart.taxAmount), style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Packaging & Handling', style: AppTextStyles.bodySecondaryMedium),
                              Text(formatPrice(cart.serviceFee), style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          
                          const Divider(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Grand Total', style: AppTextStyles.h2),
                              Text(
                                formatPrice(cart.total),
                                style: AppTextStyles.priceLarge.copyWith(fontSize: 20),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 3. Proceed to Checkout CTA
                          CustomButton(
                            text: 'Proceed to Payment',
                            onPressed: () {
                              PaymentSheet.show(context);
                            },
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
