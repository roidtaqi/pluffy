import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/data/cart_repository.dart';
import '../../orders/data/orders_repository.dart';

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.6,
          child: PaymentSheet(),
        );
      },
    );
  }

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  String _selectedMethodId = 'wallet';
  bool _isPaying = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'wallet',
      'title': 'Pluffy Pay Wallet',
      'subtitle': 'Balance: \$50.00',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'card',
      'title': 'Credit/Debit Card',
      'subtitle': 'Visa ending in 4321',
      'icon': Icons.credit_card_outlined,
    },
    {
      'id': 'gpay',
      'title': 'Google Pay',
      'subtitle': 'Fast & secure checkout',
      'icon': Icons.payment_outlined,
    },
  ];

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    final activeOutlet = ref.read(activeOutletProvider);
    
    setState(() {
      _isPaying = true;
    });

    // Simulating high-fidelity network authorization spinner
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final selectedMethod = _paymentMethods.firstWhere((m) => m['id'] == _selectedMethodId);
    
    // 1. Write order to global orders database
    final orderId = ref.read(ordersProvider.notifier).placeOrder(
          items: cart.items,
          subtotal: cart.subtotal,
          discount: cart.discountAmount,
          tax: cart.taxAmount,
          serviceFee: cart.serviceFee,
          total: cart.total,
          outletName: activeOutlet.name,
          paymentMethod: selectedMethod['title'],
          voucherCode: cart.appliedVoucherCode,
        );

    // 2. Adjust loyalty points (1 point per dollar spent)
    ref.read(loyaltyPointsProvider.notifier).addPoints(cart.total.toInt());
    
    // 3. Earn stamps (1 stamp per order containing items)
    if (cart.items.isNotEmpty) {
      ref.read(loyaltyStampsProvider.notifier).addStamps(1);
    }

    // 4. Clear active checkout cart
    ref.read(cartProvider.notifier).clear();

    setState(() {
      _isPaying = false;
    });

    // 5. Dismiss modal sheet and go to Order Success route
    Navigator.pop(context);
    context.go('/order-success?orderId=$orderId');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Indicator handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Payment Method',
            style: AppTextStyles.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Confirm payment method to place order',
            style: AppTextStyles.bodySecondary,
          ),
          
          const SizedBox(height: 24),
          
          // Payment List
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedMethodId == method['id'];

                return GestureDetector(
                  onTap: _isPaying
                      ? null
                      : () {
                          setState(() {
                            _selectedMethodId = method['id'];
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardBg : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'] as String,
                                style: AppTextStyles.h3.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method['subtitle'] as String,
                                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Action Bottom Panel
          Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Payment', style: AppTextStyles.bodyMedium),
                    Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style: AppTextStyles.priceLarge.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: _isPaying ? 'Authorizing...' : 'Pay Now — \$${cart.total.toStringAsFixed(2)}',
                  isLoading: _isPaying,
                  onPressed: _isPaying ? null : _processPayment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
