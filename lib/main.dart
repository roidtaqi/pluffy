import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routing/app_router.dart';
import 'app/theme/app_theme.dart';
import 'shared/widgets/global_notification_overlay.dart';
import 'features/orders/data/orders_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PluffyApp()));
}

class PluffyApp extends ConsumerWidget {
  const PluffyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize ordersProvider to start the local admin server immediately on boot
    ref.watch(ordersProvider);

    return MaterialApp.router(
      title: 'Pluffy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      builder: (context, child) {
        return Stack(children: [?child, const GlobalNotificationOverlay()]);
      },
    );
  }
}
