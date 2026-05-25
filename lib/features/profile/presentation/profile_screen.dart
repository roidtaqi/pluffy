import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';
import '../../orders/data/orders_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _copyVoucherCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher code "$code" copied to clipboard!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(loyaltyPointsProvider);
    final stamps = ref.watch(loyaltyStampsProvider);
    final ordersState = ref.watch(ordersProvider);
    final profileAsync = ref.watch(userProfileProvider);

    final userName = profileAsync.maybeWhen(
      data: (user) => user.name,
      orElse: () => MockData.userName,
    );
    final userEmail = profileAsync.maybeWhen(
      data: (user) => user.email,
      orElse: () => MockData.userEmail,
    );
    final membershipTier = profileAsync.maybeWhen(
      data: (user) => user.membershipTier,
      orElse: () => MockData.membershipTier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // 1. User Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 8),
                          
                          // Member Tier Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars, color: AppColors.cardBg, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  membershipTier,
                                  style: AppTextStyles.badgeText.copyWith(
                                    color: AppColors.cardBg,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 2. Loyalty stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 24),
                          const SizedBox(height: 6),
                          Text('$points pts', style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Text(
                            'Loyalty Points',
                            style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cake, color: AppColors.primary, size: 24),
                          const SizedBox(height: 6),
                          Text('$stamps / 10', style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Text(
                            'Active Stamps',
                            style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // 3. Voucher Wallet Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('My Voucher Wallet', style: AppTextStyles.h2),
              ),
            ),
            const SizedBox(height: 10),
            
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: MockData.promoBanners.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final voucher = MockData.promoBanners[index];
                  return GestureDetector(
                    onTap: () => _copyVoucherCode(context, voucher['code']!),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(voucher['image']!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  voucher['title']!,
                                  style: AppTextStyles.h3.copyWith(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            voucher['description']!,
                            style: AppTextStyles.bodySecondary.copyWith(fontSize: 10, height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border, width: 0.6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  voucher['code']!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy, size: 10, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 28),

            // Pluffy Admin Web Server Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Pluffy Admin Portal', style: AppTextStyles.h2),
              ),
            ),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.computer, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Web Admin Server Active',
                                style: AppTextStyles.h3.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Listening on port ${ordersState.serverPort}',
                                    style: AppTextStyles.bodySecondaryMedium.copyWith(
                                      color: AppColors.success,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      'Buka link berikut di browser web Anda (Chrome/Firefox) untuk mengelola dapur, mengubah status hidangan secara manual, dan memicu notifikasi pelanggan!',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'http://127.0.0.1:${ordersState.serverPort}/admin',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: 'http://127.0.0.1:${ordersState.serverPort}/admin'));
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Link Web Admin disalin ke clipboard!'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 28),
            
            // 4. Mock Account Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Account Settings', style: AppTextStyles.h2),
              ),
            ),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.payment,
                      title: 'Payment Methods',
                      subtitle: 'Manage cards and Pluffy Pay wallet',
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: 'Add delivery locations',
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.support_agent,
                      title: 'Help & Customer Service',
                      subtitle: 'Get support or contact outlets',
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About Pluffy Café',
                      subtitle: 'Version 1.0.0 Stable Build',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.border, size: 20),
      onTap: () {
        // Mock action, fully structured
      },
    );
  }
}
