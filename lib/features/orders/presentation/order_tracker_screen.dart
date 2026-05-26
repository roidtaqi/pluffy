import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/providers/global_providers.dart';
import '../data/orders_repository.dart';

class OrderTrackerScreen extends ConsumerWidget {
  const OrderTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final activeOrder = ordersState.activeOrder;

    // Fallback in case activeOrder is completed or empty (e.g. testing completed order)
    final order = activeOrder ??
        (ordersState.orders.isNotEmpty
            ? ordersState.orders.first
            : null);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracker')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.border),
                const SizedBox(height: 16),
                Text('No order found to track', style: AppTextStyles.h3),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Go to Menu',
                  onPressed: () => context.go('/menu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentStatusIndex = order.status.index;

    // Stepper definition
    final steps = [
      {
        'title': 'Order Placed',
        'desc': 'We have received your order and payment.',
        'time': 'Just now',
      },
      {
        'title': 'In the Kitchen',
        'desc': 'Our chefs are slow-baking your Japanese soufflés with love.',
        'time': currentStatusIndex >= 1 ? 'In progress' : 'Pending',
      },
      {
        'title': 'Ready at Counter',
        'desc': 'Your warm desserts are ready! Please present your ID ${order.id} at the counter.',
        'time': currentStatusIndex >= 2 ? 'Ready' : 'Pending',
      },
      {
        'title': 'Completed',
        'desc': 'Enjoy your premium dessert! Don\'t forget to stamp your loyalty card.',
        'time': currentStatusIndex >= 3 ? 'Enjoyed' : 'Pending',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/orders');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${order.id}',
                            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pickup location: ${order.outletName}',
                            style: AppTextStyles.bodySecondaryMedium.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              Text('Live Status Tracker', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Kitchen status updates automatically from the admin board.',
                    style: AppTextStyles.bodySecondaryMedium.copyWith(
                      color: AppColors.success,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Vertical Stepper Timeline
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isDone = index <= currentStatusIndex;
                  final isActive = index == currentStatusIndex;
                  final isLast = index == steps.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicator Timeline Left
                        Column(
                          children: [
                            // Glowing or pulsing node
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.9, end: isActive ? 1.1 : 1.0),
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDone ? AppColors.primary : AppColors.background,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDone ? AppColors.primary : AppColors.border,
                                        width: 2,
                                      ),
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.3),
                                                blurRadius: 6,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: isDone
                                          ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: AppColors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            // Line connecting nodes
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: index < currentStatusIndex ? AppColors.primary : AppColors.border,
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Stepper Description Right
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      step['title']!,
                                      style: AppTextStyles.h3.copyWith(
                                        color: isDone ? AppColors.textMain : AppColors.textSecondary,
                                        fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      step['time']!,
                                      style: AppTextStyles.bodySecondary.copyWith(
                                        fontSize: 10,
                                        color: isActive
                                            ? AppColors.primary
                                            : isDone
                                                ? AppColors.success
                                                : AppColors.textSecondary,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step['desc']!,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    fontSize: 12,
                                    color: isDone ? AppColors.textMain.withValues(alpha: 0.8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const Divider(height: 24),
              
              // Summary details
              if (order.items.isNotEmpty) ...[
                Text('Items Ordered', style: AppTextStyles.h2),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.quantity} x ${item.product.name}',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            formatPrice(item.totalPrice),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],
              
              CustomButton(
                text: 'Done',
                onPressed: () {
                  context.go('/orders');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
