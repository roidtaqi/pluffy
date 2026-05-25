import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../providers/global_providers.dart';

class GlobalNotificationOverlay extends ConsumerStatefulWidget {
  const GlobalNotificationOverlay({Key? key}) : super(key: key);

  @override
  ConsumerState<GlobalNotificationOverlay> createState() => _GlobalNotificationOverlayState();
}

class _GlobalNotificationOverlayState extends ConsumerState<GlobalNotificationOverlay> {
  Timer? _dismissTimer;
  InAppNotification? _currentNotification;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        ref.read(inAppNotificationProvider.notifier).state = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(inAppNotificationProvider);

    if (notification == null) {
      _currentNotification = null;
      return const SizedBox.shrink();
    }

    // Trigger timer only on new notification
    if (_currentNotification != notification) {
      _currentNotification = notification;
      _startDismissTimer();
    }

    IconData statusIcon = Icons.notifications_active;
    Color iconColor = AppColors.primary;

    if (notification.title.contains("Kitchen") || 
        notification.title.contains("preparing") || 
        notification.title.contains("Kitchen") ||
        notification.statusName.contains("Kitchen") ||
        notification.statusName.contains("Kitchen")) {
      statusIcon = Icons.restaurant_menu;
      iconColor = AppColors.accent;
    } else if (notification.title.contains("Ready") || 
               notification.title.contains("Siap") || 
               notification.statusName.contains("Ready")) {
      statusIcon = Icons.celebration;
      iconColor = AppColors.success;
    } else if (notification.title.contains("Completed") || 
               notification.title.contains("Selesai") || 
               notification.statusName.contains("Completed")) {
      statusIcon = Icons.favorite;
      iconColor = AppColors.primary;
    } else {
      statusIcon = Icons.receipt_long;
      iconColor = AppColors.textSecondary;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textMain.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                // Glowing Circle Badge Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                
                // Text Message Column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textMain,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                  onPressed: () {
                    ref.read(inAppNotificationProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
        )
        .animate(key: ValueKey(notification.orderId + notification.statusName))
        .slideY(begin: -1.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack)
        .fade(duration: 300.ms),
      ),
    );
  }
}
