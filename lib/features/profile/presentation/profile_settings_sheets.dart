import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/data/mock_data.dart';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../outlet/domain/outlet.dart';
import '../data/profile_preferences.dart';

class ProfileSettingsSheets {
  ProfileSettingsSheets._();

  static void showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.78,
          child: Consumer(
            builder: (context, ref, child) {
              final preferences = ref.watch(profilePreferencesProvider);

              return _SettingsSheet(
                title: 'Metode Pembayaran',
                subtitle:
                    'Pilih metode utama yang akan digunakan saat pembayaran.',
                action: CustomButton(
                  text: 'Tambah Kartu',
                  onPressed: () => _showAddCardDialog(context, ref),
                ),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: preferences.paymentMethods.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final method = preferences.paymentMethods[index];
                    return _PreferenceTile(
                      icon: paymentMethodIcon(method.type),
                      title: method.title,
                      subtitle: method.isDefault
                          ? '${method.subtitle} - Metode utama'
                          : method.subtitle,
                      isSelected: method.isDefault,
                      onTap: () {
                        ref
                            .read(profilePreferencesProvider.notifier)
                            .setDefaultPaymentMethod(method.id);
                      },
                      onDelete: method.canRemove
                          ? () {
                              ref
                                  .read(profilePreferencesProvider.notifier)
                                  .removePaymentMethod(method.id);
                            }
                          : null,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void showSavedAddresses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.78,
          child: Consumer(
            builder: (context, ref, child) {
              final addresses = ref.watch(profilePreferencesProvider).addresses;

              return _SettingsSheet(
                title: 'Alamat Tersimpan',
                subtitle:
                    'Simpan alamat agar detail pengantaran lebih cepat diisi.',
                action: CustomButton(
                  text: 'Tambah Alamat',
                  onPressed: () => _showAddAddressDialog(context, ref),
                ),
                child: addresses.isEmpty
                    ? const _EmptyState(
                        icon: Icons.location_on_outlined,
                        title: 'Belum ada alamat tersimpan',
                        subtitle:
                            'Tambahkan alamat rumah atau kantor untuk digunakan nanti.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: addresses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          final details = [
                            address.address,
                            if (address.notes.isNotEmpty) address.notes,
                            if (address.isDefault) 'Alamat utama',
                          ].join(' - ');

                          return _PreferenceTile(
                            icon: Icons.location_on_outlined,
                            title: address.label,
                            subtitle: details,
                            isSelected: address.isDefault,
                            onTap: () {
                              ref
                                  .read(profilePreferencesProvider.notifier)
                                  .setDefaultAddress(address.id);
                            },
                            onDelete: () {
                              ref
                                  .read(profilePreferencesProvider.notifier)
                                  .removeAddress(address.id);
                            },
                          );
                        },
                      ),
              );
            },
          ),
        );
      },
    );
  }

  static void showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.84,
          child: Consumer(
            builder: (context, ref, child) {
              final activeOutlet = ref.watch(activeOutletProvider);
              return _SettingsSheet(
                title: 'Bantuan & Layanan Pelanggan',
                subtitle:
                    'Hubungi tim Pluffy atau lihat jawaban dari pertanyaan umum.',
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _ContactSection(outlet: activeOutlet),
                    const SizedBox(height: 18),
                    Text('Pertanyaan Umum', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    const _FaqTile(
                      question: 'Bagaimana cara mengganti outlet pengambilan?',
                      answer:
                          'Tekan nama outlet di bagian atas halaman Beranda, lalu pilih outlet yang kamu inginkan sebelum membuat pesanan.',
                    ),
                    const _FaqTile(
                      question: 'Di mana saya bisa melihat status pesanan?',
                      answer:
                          'Buka menu Pesanan pada navigasi bawah. Pesanan aktif akan menampilkan status terbaru dari dapur.',
                    ),
                    const _FaqTile(
                      question: 'Bagaimana menggunakan kode voucher?',
                      answer:
                          'Salin kode dari Dompet Voucher, lalu masukkan kode tersebut di keranjang sebelum memilih metode pembayaran.',
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: _SettingsSheet(
            title: 'Tentang Pluffy Cafe',
            subtitle: 'Informasi aplikasi dan layanan Pluffy.',
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 104,
                    height: 104,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pluffy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi 1.0.0 - Rilis Stabil',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 18),
                Text(
                  'Pluffy membantu kamu memilih outlet, memesan hidangan hangat, memantau proses dapur, dan mengambil pesanan di konter yang tepat.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular,
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Pluffy',
                      applicationVersion: '1.0.0',
                      applicationIcon: Image.asset(
                        'assets/images/logo.png',
                        width: 56,
                        height: 56,
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Lihat Lisensi Aplikasi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _showAddCardDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    final holderController = TextEditingController();
    final numberController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Kartu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: holderController,
                  hintText: 'Nama pemilik kartu',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Nama pemilik wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: numberController,
                  hintText: 'Nomor kartu',
                  prefixIcon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    if (digits.length < 12) {
                      return 'Masukkan nomor kartu yang valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ref
                    .read(profilePreferencesProvider.notifier)
                    .addCard(
                      holderName: holderController.text.trim(),
                      cardNumber: numberController.text,
                    );
                Navigator.pop(dialogContext);
                _showMessage(context, 'Kartu berhasil ditambahkan.');
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    holderController.dispose();
    numberController.dispose();
  }

  static Future<void> _showAddAddressDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Alamat'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: labelController,
                    hintText: 'Label alamat, misalnya Rumah',
                    prefixIcon: Icons.label_outline,
                    validator: (value) {
                      if ((value?.trim() ?? '').isEmpty) {
                        return 'Label alamat wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: addressController,
                    hintText: 'Alamat lengkap',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (value) {
                      if ((value?.trim() ?? '').isEmpty) {
                        return 'Alamat lengkap wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: notesController,
                    hintText: 'Catatan alamat (opsional)',
                    prefixIcon: Icons.notes_outlined,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ref
                    .read(profilePreferencesProvider.notifier)
                    .addAddress(
                      label: labelController.text.trim(),
                      address: addressController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                Navigator.pop(dialogContext);
                _showMessage(context, 'Alamat berhasil disimpan.');
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    labelController.dispose();
    addressController.dispose();
    notesController.dispose();
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

IconData paymentMethodIcon(SavedPaymentMethodType type) {
  switch (type) {
    case SavedPaymentMethodType.wallet:
      return Icons.account_balance_wallet_outlined;
    case SavedPaymentMethodType.card:
      return Icons.credit_card_outlined;
    case SavedPaymentMethodType.digitalWallet:
      return Icons.payment_outlined;
  }
}

class _SettingsSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  const _SettingsSheet({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
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
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySecondary),
            const SizedBox(height: 18),
            Expanded(child: child),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.cardBg : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary)
              else if (onDelete != null)
                IconButton(
                  tooltip: 'Hapus',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  static const customerServiceEmail = 'halo@pluffy.cafe';

  final Outlet outlet;

  const _ContactSection({required this.outlet});

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri)) return;
    } catch (_) {}

    if (!context.mounted) return;
    ProfileSettingsSheets._showMessage(
      context,
      'Aplikasi untuk membuka kontak belum tersedia.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outlet Aktif', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(outlet.name, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 2),
          Text(outlet.address, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _open(
                  context,
                  Uri(scheme: 'tel', path: outlet.phone.replaceAll(' ', '')),
                ),
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Telepon Outlet'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open(
                  context,
                  Uri(scheme: 'mailto', path: customerServiceEmail),
                ),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Email Layanan'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Outlet lain yang tersedia: ${MockData.outlets.length - 1}',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      title: Text(question, style: AppTextStyles.bodyMedium),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(answer, style: AppTextStyles.bodySecondary),
        ),
      ],
    );
  }
}
