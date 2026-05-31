import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class UserProfileAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double borderWidth;

  const UserProfileAvatar({
    super.key,
    required this.name,
    required this.size,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: ClipOval(child: _AvatarInitials(name: name)),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final String name;

  const _AvatarInitials({required this.name});

  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? 'P'
        : [
            parts.first[0],
            if (parts.length > 1) parts.last[0],
          ].join().toUpperCase();

    return ColoredBox(
      color: AppColors.cardBg,
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
