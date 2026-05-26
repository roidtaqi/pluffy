import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/data/cart_repository.dart';
import '../data/orders_repository.dart';
import '../domain/order.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerReorder(OrderModel order) {
    // 1. Copy past items with their exact customizations into active cart
    final cartNotifier = ref.read(cartProvider.notifier);

    // In our mock history, items might be empty, so we populate with a popular item if so,
    // but if items exist, we copy them!
    if (order.items.isEmpty) {
      // Seed with a mock default popular product for historical reorder simulation
      final mockProduct = ref.read(cartProvider).items.isNotEmpty
          ? ref.read(cartProvider).items.first.product
          : null;
      if (mockProduct != null) {
        cartNotifier.addItem(product: mockProduct);
      } else {
        // Fallback default
        cartNotifier.addItem(
          product: MockData.products.firstWhere(
            (p) => p.id == 'prod_original_souffle',
          ),
          selectedSweetness: '100%',
        );
      }
    } else {
      for (var item in order.items) {
        cartNotifier.addItem(
          product: item.product,
          quantity: item.quantity,
          selectedSweetness: item.selectedSweetness,
          selectedIce: item.selectedIce,
          selectedTemperature: item.selectedTemperature,
          selectedAddons: item.selectedAddons,
        );
      }
    }

    // 2. Direct to Cart
    context.go('/cart');

    // 3. Inform the user
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.shopping_bag, color: Colors.white),
            SizedBox(width: 12),
            Text('Past order loaded! Reorder items added to cart.'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final activeOrder = ordersState.activeOrder;
    final pastOrders = ordersState.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Active Order'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. ACTIVE ORDER TAB
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: activeOrder != null
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activeOrder.status.displayName,
                                style: AppTextStyles.badgeText.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              activeOrder.id,
                              style: AppTextStyles.bodySecondaryMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Preparing your soufflés...',
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeOrder.status.description,
                          style: AppTextStyles.bodySecondary,
                        ),

                        const SizedBox(height: 24),

                        // Small high-fidelity stepper simulation visual
                        Row(
                          children: List.generate(4, (index) {
                            final int currentStepIndex =
                                activeOrder.status.index;
                            final bool isDone = index <= currentStepIndex;
                            final bool isLast = index == 3;

                            return Expanded(
                              child: Row(
                                children: [
                                  // Circle
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? AppColors.primary
                                          : AppColors.background,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDone
                                            ? AppColors.primary
                                            : AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: isDone
                                          ? const Icon(
                                              Icons.check,
                                              size: 10,
                                              color: AppColors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                  // Line
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        height: 3,
                                        color: index < currentStepIndex
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),

                        const Divider(height: 48),

                        // Total breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${activeOrder.items.fold(0, (sum, item) => sum + item.quantity)} items from ${activeOrder.outletName.replaceFirst('Pluffy - ', '')}',
                              style: AppTextStyles.bodySecondaryMedium,
                            ),
                            Text(
                              formatPrice(activeOrder.total),
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Track Order Progress 🥞',
                          onPressed: () {
                            context.push('/order-tracker');
                          },
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 60.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('No Active Orders', style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Text(
                          'You don\'t have any pending orders. Go to the menu to satisfy your cravings!',
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        CustomButton(
                          text: 'Order Now',
                          width: 160,
                          onPressed: () {
                            ref.read(navigationIndexProvider.notifier).state =
                                1;
                            context.go('/menu');
                          },
                        ),
                      ],
                    ),
                  ),
          ),

          // 2. ORDER HISTORY TAB
          ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: pastOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = pastOrders[index];
              final dateString = DateFormat(
                'MMM dd, yyyy • hh:mm a',
              ).format(order.orderDate);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.outletName,
                              style: AppTextStyles.h3.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateString,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Completed',
                            style: AppTextStyles.badgeText.copyWith(
                              color: AppColors.success,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Price details and quick reorder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Payment',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatPrice(order.total),
                              style: AppTextStyles.priceLarge.copyWith(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton.icon(
                          onPressed: () => _triggerReorder(order),
                          icon: const Icon(Icons.replay, size: 14),
                          label: const Text('Reorder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: AppTextStyles.buttonText.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
