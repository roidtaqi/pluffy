import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/user_profile_avatar.dart';
import 'profile_settings_sheets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _copyVoucherCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode voucher "$code" berhasil disalin.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    UserProfile user,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    bool isSaving = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        'Ubah Profil',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Perbarui nama, email, atau kata sandi akun Pluffy.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: nameController,
                        hintText: 'Nama lengkap',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if ((value?.trim() ?? '').isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Email wajib diisi';
                          if (!email.contains('@')) {
                            return 'Format email belum valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Kata sandi baru (opsional)',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          final password = value ?? '';
                          if (password.isNotEmpty && password.length < 6) {
                            return 'Minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: AppTextStyles.bodySecondaryMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      CustomButton(
                        text: isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                        isLoading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                setSheetState(() {
                                  isSaving = true;
                                  errorMessage = null;
                                });

                                final error = await ref
                                    .read(userProfileProvider.notifier)
                                    .updateProfileDetails(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                    );

                                if (!sheetContext.mounted) return;

                                if (error != null) {
                                  setSheetState(() {
                                    isSaving = false;
                                    errorMessage = error;
                                  });
                                  return;
                                }

                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Profil berhasil diperbarui.',
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
    });
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Keluar dari akun?', style: AppTextStyles.h3),
              ),
            ],
          ),
          content: Text(
            'Kamu akan keluar dari akun Pluffy saat ini. Kamu perlu masuk kembali untuk melihat profil, poin loyalitas, dan riwayat pesanan.',
            style: AppTextStyles.bodySecondary,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    await ref.read(userProfileProvider.notifier).logout();
    if (!context.mounted) return;

    context.go('/auth');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(loyaltyPointsProvider);
    final stamps = ref.watch(loyaltyStampsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final user = profileAsync.valueOrNull;

    if (profileAsync.isLoading && user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Saya'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 22),
                Text('Login untuk melihat profil', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Profil, poin loyalitas, dan riwayat pesanan akan aktif setelah kamu masuk atau membuat akun.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Masuk / Daftar',
                  onPressed: () => context.go('/auth?redirect=/profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userName = user.name;
    final userEmail = user.email;
    final membershipTier = user.membershipTier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Ubah profil',
            onPressed: () => _showEditProfileSheet(context, ref, user),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
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
                    UserProfileAvatar(name: userName, size: 68),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: AppTextStyles.h2),
                          const SizedBox(height: 2),
                          Text(userEmail, style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 8),

                          // Member Tier Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: AppColors.cardBg,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _membershipTierLabel(membershipTier),
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
                    IconButton(
                      tooltip: 'Ubah profil',
                      onPressed: () =>
                          _showEditProfileSheet(context, ref, user),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
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
                        color: AppColors.cardBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text('$points poin', style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Text(
                            'Poin Loyalitas',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 11,
                            ),
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
                        color: AppColors.cardBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cake,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text('$stamps / 10', style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Text(
                            'Stempel Aktif',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 11,
                            ),
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
                child: Text('Dompet Voucher Saya', style: AppTextStyles.h2),
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
                              Text(
                                voucher['image']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  voucher['title']!,
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            voucher['description']!,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 10,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border,
                                width: 0.6,
                              ),
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
                                const Icon(
                                  Icons.copy,
                                  size: 10,
                                  color: AppColors.primary,
                                ),
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

            // 4. Mock Account Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Pengaturan Akun', style: AppTextStyles.h2),
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
                      icon: Icons.edit_outlined,
                      title: 'Ubah Profil',
                      subtitle: 'Perbarui nama, email, dan kata sandi',
                      onTap: () => _showEditProfileSheet(context, ref, user),
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.payment,
                      title: 'Metode Pembayaran',
                      subtitle: 'Kelola kartu dan dompet Pluffy Pay',
                      onTap: () =>
                          ProfileSettingsSheets.showPaymentMethods(context),
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Alamat Tersimpan',
                      subtitle: 'Tambahkan lokasi pengantaran',
                      onTap: () =>
                          ProfileSettingsSheets.showSavedAddresses(context),
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.support_agent,
                      title: 'Bantuan & Layanan Pelanggan',
                      subtitle: 'Dapatkan bantuan atau hubungi outlet',
                      onTap: () => ProfileSettingsSheets.showHelp(context),
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'Tentang Pluffy Cafe',
                      subtitle: 'Versi 1.0.0 - Rilis Stabil',
                      onTap: () => ProfileSettingsSheets.showAbout(context),
                    ),
                    const Divider(indent: 54, endIndent: 16),
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Keluar',
                      subtitle: 'Keluar dari akun ini',
                      iconColor: AppColors.error,
                      onTap: () => _showLogoutConfirmation(context, ref),
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
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.border,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  String _membershipTierLabel(String membershipTier) {
    switch (membershipTier.toLowerCase()) {
      case 'bronze member':
        return 'Anggota Perunggu';
      case 'silver member':
        return 'Anggota Perak';
      case 'gold member':
        return 'Anggota Emas';
      default:
        return membershipTier;
    }
  }
}
