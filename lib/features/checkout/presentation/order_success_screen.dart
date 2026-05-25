import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../orders/data/orders_repository.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final String orderId;

  const OrderSuccessScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    
    // Find the placed order to display summary
    final order = ordersState.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => ordersState.orders.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Animated success illustration
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 72,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                Text(
                  'Order Placed!',
                  style: AppTextStyles.brandHeader.copyWith(
                    fontSize: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been sent to the kitchen',
                  style: AppTextStyles.bodySecondaryMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 36),
                
                // Receipt Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Receipt ID', style: AppTextStyles.bodySecondaryMedium),
                          Text(
                            order.id,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Outlet', style: AppTextStyles.bodySecondaryMedium),
                          Text(
                            order.outletName.replaceFirst('Pluffy - ', ''),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 28),
                      
                      // Items breakdown
                      Text(
                        'Items Summary',
                        style: AppTextStyles.h3.copyWith(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity} x ${item.product.name}',
                                  style: AppTextStyles.bodyRegular.copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                formatPrice(item.totalPrice),
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      const Divider(height: 28),
                      
                      // Totals section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: AppTextStyles.bodySecondary),
                          Text(formatPrice(order.subtotal), style: AppTextStyles.bodySecondaryMedium),
                        ],
                      ),
                      
                      if (order.discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount', style: AppTextStyles.bodySecondary.copyWith(color: AppColors.success)),
                            Text(
                              '-${formatPrice(order.discount)}',
                              style: AppTextStyles.bodySecondaryMedium.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service Tax (10%)', style: AppTextStyles.bodySecondary),
                          Text(formatPrice(order.tax), style: AppTextStyles.bodySecondaryMedium),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Packaging Fee', style: AppTextStyles.bodySecondary),
                          Text(formatPrice(order.serviceFee), style: AppTextStyles.bodySecondaryMedium),
                        ],
                      ),
                      
                      const Divider(height: 28),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: AppTextStyles.h2),
                          Text(
                            formatPrice(order.total),
                            style: AppTextStyles.priceLarge.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                CustomButton(
                  text: 'Track My Order 🥞',
                  onPressed: () {
                    context.go('/order-tracker');
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Go back to Home',
                  isSecondary: true,
                  onPressed: () {
                    // Update navigation tab to home
                    ref.read(navigationIndexProvider.notifier).state = 0;
                    context.go('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
