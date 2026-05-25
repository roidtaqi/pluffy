import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/providers/global_providers.dart';

class LoyaltyCard extends ConsumerWidget {
  const LoyaltyCard({Key? key}) : super(key: key);

  void _showMockQrCode(BuildContext context, UserProfile? user, int points) {
    final displayName = user?.name ?? 'Guest';
    final membershipTier = user?.membershipTier ?? 'Bronze Member';
    final tierCode = membershipTier.split(' ').first.toUpperCase();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.border, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'My Pluffy Card',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan at the counter to earn points and stamps',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),

                // Gorgeous custom pulsing mock barcode/QR
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.98, end: 1.02),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  onEnd: () {},
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Render a simulated hi-fi QR code
                            Container(
                              width: 180,
                              height: 180,
                              color: AppColors.white,
                              child: CustomPaint(painter: QrPainter()),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'PLUFFY-$points-$tierCode',
                              style: AppTextStyles.bodyMedium.copyWith(
                                letterSpacing: 3.0,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(displayName, style: AppTextStyles.h3),
                Text(
                  'Pluffy $membershipTier',
                  style: AppTextStyles.bodySecondaryMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stamps = ref.watch(loyaltyStampsProvider);
    final points = ref.watch(loyaltyPointsProvider);
    final user = ref.watch(userProfileProvider).valueOrNull;
    final membershipTier = user?.membershipTier ?? 'Bronze Member';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background soft decor
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.stars,
              size: 150,
              color: AppColors.border.withOpacity(0.2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pluffy Loyalty Card',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          membershipTier,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showMockQrCode(context, user, points),
                      icon: const Icon(
                        Icons.qr_code_2,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Points view
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$points', style: AppTextStyles.loyaltyPointsText),
                    const SizedBox(width: 4),
                    Text(
                      'points',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stamp tracker header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stamp Rewards',
                      style: AppTextStyles.bodySecondaryMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$stamps / ${MockData.stampsGoal}',
                      style: AppTextStyles.bodyRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Stamps grid (10 steps)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(MockData.stampsGoal, (index) {
                    final isStamped = index < stamps;
                    return Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isStamped
                            ? AppColors.primary
                            : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isStamped
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isStamped ? Icons.cake : Icons.circle,
                          size: isStamped ? 14 : 6,
                          color: isStamped ? AppColors.white : AppColors.border,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 14),

                // Next reward subtitle
                Text(
                  stamps >= MockData.stampsGoal
                      ? 'Congratulations! Claim your free soufflé at checkout!'
                      : 'Earn ${MockData.stampsGoal - stamps} more stamps for a free Japanese Soufflé!',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    color: stamps >= MockData.stampsGoal
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: stamps >= MockData.stampsGoal
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a high-fidelity simulated QR Code
class QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMain
      ..style = PaintingStyle.fill;

    final double squareSize = size.width / 12;

    // Helper to draw a square block
    void drawBlock(int x, int y, {int sizeMultiplier = 1}) {
      canvas.drawRect(
        Rect.fromLTWH(
          x * squareSize,
          y * squareSize,
          squareSize * sizeMultiplier,
          squareSize * sizeMultiplier,
        ),
        paint,
      );
    }

    // Finder patterns (top-left, top-right, bottom-left)
    void drawFinderPattern(int startX, int startY) {
      // Outer 7x7 box
      paint.color = AppColors.textMain;
      canvas.drawRect(
        Rect.fromLTWH(
          startX * squareSize,
          startY * squareSize,
          7 * squareSize,
          7 * squareSize,
        ),
        paint,
      );
      paint.color = AppColors.white;
      canvas.drawRect(
        Rect.fromLTWH(
          (startX + 1) * squareSize,
          (startY + 1) * squareSize,
          5 * squareSize,
          5 * squareSize,
        ),
        paint,
      );
      paint.color = AppColors.textMain;
      canvas.drawRect(
        Rect.fromLTWH(
          (startX + 2) * squareSize,
          (startY + 2) * squareSize,
          3 * squareSize,
          3 * squareSize,
        ),
        paint,
      );
    }

    // Draw three finders
    drawFinderPattern(0, 0);
    drawFinderPattern(5, 0);
    drawFinderPattern(0, 5);

    // Dynamic mock random-looking details
    paint.color = AppColors.textMain;
    drawBlock(0, 4);
    drawBlock(2, 4);
    drawBlock(3, 4);
    drawBlock(4, 4);

    drawBlock(4, 0);
    drawBlock(4, 2);

    drawBlock(7, 7);
    drawBlock(8, 7);
    drawBlock(9, 7);
    drawBlock(10, 7);

    drawBlock(7, 8);
    drawBlock(9, 8);
    drawBlock(11, 8);

    drawBlock(8, 9);
    drawBlock(10, 9);

    drawBlock(7, 10);
    drawBlock(8, 10);
    drawBlock(11, 10);

    drawBlock(9, 11);
    drawBlock(10, 11);

    drawBlock(4, 6);
    drawBlock(6, 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
