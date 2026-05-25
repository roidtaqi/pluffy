import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';
import '../../menu/domain/product.dart';
import '../../menu/presentation/product_detail_sheet.dart';
import '../../outlet/presentation/outlet_selector_sheet.dart';
import 'widgets/loyalty_card.dart';
import 'widgets/promo_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOutlet = ref.watch(activeOutletProvider);
    final popularProducts = MockData.products.where((p) => p.isPopular).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _getGreeting(),
              style: AppTextStyles.bodySecondaryMedium.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => OutletSelectorSheet.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeOutlet.name,
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Open simple notification popup or route to profile
              context.go('/profile');
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${MockData.userName.split(' ').first}',
                        style: AppTextStyles.brandHeader.copyWith(
                          fontSize: 28,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Craving some fluffy soufflés today? 🥞',
                        style: AppTextStyles.bodySecondaryMedium,
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', // Premium mock avatar
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Loyalty Card
              const LoyaltyCard(),
              
              const SizedBox(height: 28),
              
              // Promos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Special Offers', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () {
                      context.go('/profile'); // Vouchers list is in Profile
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const PromoCarousel(),
              
              const SizedBox(height: 28),
              
              // Popular Items Horizontal list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Items', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () {
                      context.go('/menu');
                    },
                    child: const Text('View Menu'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: popularProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final product = popularProducts[index];
                    return GestureDetector(
                      onTap: () => ProductDetailSheet.show(context, product),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mock illustration card inside
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Title & Price
                            Text(
                              product.name,
                              style: AppTextStyles.h3.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.description,
                              style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${product.basePrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.priceRegular,
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 14,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
