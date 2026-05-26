import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';

class OutletSelectorSheet extends ConsumerWidget {
  const OutletSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.65,
          child: OutletSelectorSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOutlet = ref.watch(activeOutletProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
            'Select Outlet',
            style: AppTextStyles.h1.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred outlet for ordering and pickup',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: MockData.outlets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final outlet = MockData.outlets[index];
                final isSelected = activeOutlet.id == outlet.id;

                return GestureDetector(
                  onTap: () {
                    ref.read(activeOutletProvider.notifier).state = outlet;
                    Navigator.pop(context);

                    // Simple snackbar
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to ${outlet.name}'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textMain.withValues(
                            alpha: isSelected ? 0.04 : 0.01,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.storefront,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    outlet.name,
                                    style: AppTextStyles.h3.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textMain,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                outlet.address,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    outlet.operatingHours,
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.phone,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    outlet.phone,
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right checkmark & distance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${outlet.distanceKm} km',
                                style: AppTextStyles.badgeText.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24,
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
        ],
      ),
    );
  }
}
