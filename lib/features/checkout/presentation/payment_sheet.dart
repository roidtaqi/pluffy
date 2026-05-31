import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/data/cart_repository.dart';
import '../../orders/data/orders_repository.dart';
import '../../profile/data/profile_preferences.dart';

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return const SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.86,
            child: PaymentSheet(),
          ),
        );
      },
    );
  }

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  late String _selectedMethodId;
  bool _didChoosePaymentMethod = false;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _selectedMethodId = ref
        .read(profilePreferencesProvider)
        .defaultPaymentMethod
        .id;
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    final activeOutlet = ref.read(activeOutletProvider);
    final user = ref.read(userProfileProvider).valueOrNull;

    if (user == null) {
      Navigator.pop(context);
      context.go('/auth?redirect=/cart');
      return;
    }

    setState(() {
      _isPaying = true;
    });

    // Simulating high-fidelity network authorization spinner
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final preferences = ref.read(profilePreferencesProvider);
    final paymentMethods = preferences.paymentMethods;
    final selectedMethodId = _didChoosePaymentMethod
        ? _selectedMethodId
        : preferences.defaultPaymentMethod.id;
    final selectedMethod = paymentMethods.firstWhere(
      (method) => method.id == selectedMethodId,
      orElse: () => paymentMethods.first,
    );

    // 1. Write order to global orders database
    final orderId = await ref
        .read(ordersProvider.notifier)
        .placeOrder(
          items: cart.items,
          subtotal: cart.subtotal,
          discount: cart.discountAmount,
          tax: cart.taxAmount,
          serviceFee: cart.serviceFee,
          total: cart.total,
          outletName: activeOutlet.name,
          paymentMethod: selectedMethod.title,
          voucherCode: cart.appliedVoucherCode,
          userId: user.id,
        );

    if (!mounted) return;

    // 2. Clear active checkout cart
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
    final preferences = ref.watch(profilePreferencesProvider);
    final paymentMethods = preferences.paymentMethods;
    final selectedMethodId = _didChoosePaymentMethod
        ? _selectedMethodId
        : preferences.defaultPaymentMethod.id;

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
            'Metode Pembayaran',
            style: AppTextStyles.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih metode pembayaran untuk membuat pesanan.',
            style: AppTextStyles.bodySecondary,
          ),

          const SizedBox(height: 24),

          // Payment List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                final isSelected = selectedMethodId == method.id;

                return GestureDetector(
                  onTap: _isPaying
                      ? null
                      : () {
                          setState(() {
                            _selectedMethodId = method.id;
                            _didChoosePaymentMethod = true;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardBg : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _paymentMethodIcon(method.type),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.title,
                                style: AppTextStyles.h3.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method.subtitle,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 12,
                                ),
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
                    Text('Total Pembayaran', style: AppTextStyles.bodyMedium),
                    Text(
                      formatPrice(cart.total),
                      style: AppTextStyles.priceLarge.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: _isPaying
                      ? 'Memproses...'
                      : 'Bayar Sekarang - ${formatPrice(cart.total)}',
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

  IconData _paymentMethodIcon(SavedPaymentMethodType type) {
    switch (type) {
      case SavedPaymentMethodType.wallet:
        return Icons.account_balance_wallet_outlined;
      case SavedPaymentMethodType.card:
        return Icons.credit_card_outlined;
      case SavedPaymentMethodType.digitalWallet:
        return Icons.payment_outlined;
    }
  }
}
