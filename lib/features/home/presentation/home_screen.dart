import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/user_profile_avatar.dart';
import '../../menu/presentation/product_detail_sheet.dart';
import '../../outlet/presentation/outlet_selector_sheet.dart';
import 'widgets/loyalty_card.dart';
import 'widgets/promo_carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _currentWitaTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentWitaTime = _witaNow();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _currentWitaTime = _witaNow();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  DateTime _witaNow() {
    return DateTime.now().toUtc().add(const Duration(hours: 8));
  }

  String _getGreeting(DateTime time) {
    final hour = time.hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final activeOutlet = ref.watch(activeOutletProvider);
    final productsAsync = ref.watch(productsProvider);
    final products = productsAsync.value ?? MockData.products;
    final popularProducts = products.where((p) => p.isPopular).toList();
    final user = ref.watch(userProfileProvider).valueOrNull;
    final firstName = user?.name.split(' ').first ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _getGreeting(_currentWitaTime),
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
                        'Hi, $firstName',
                        style: AppTextStyles.brandHeader.copyWith(
                          fontSize: 28,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mau pesan yang lembut hari ini?',
                        style: AppTextStyles.bodySecondaryMedium,
                      ),
                    ],
                  ),
                  UserProfileAvatar(
                    name: user?.name ?? 'Pengguna Pluffy',
                    size: 50,
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
                  Text('Promo Hari Ini', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () {
                      context.go('/profile'); // Vouchers list is in Profile
                    },
                    child: const Text('Lihat Semua'),
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
                  Text('Menu Favorit', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () {
                      context.go('/menu');
                    },
                    child: const Text('Buka Menu'),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final product = popularProducts[index];
                    return GestureDetector(
                      onTap: () => ProductDetailSheet.show(context, product),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.0,
                          ),
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
                                  border: Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1,
                                  ),
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
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatPrice(product.basePrice),
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
