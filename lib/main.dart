import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routing/app_router.dart';
import 'app/theme/app_theme.dart';
import 'shared/widgets/global_notification_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PluffyApp(),
    ),
  );
}

class PluffyApp extends StatelessWidget {
  const PluffyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pluffy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const GlobalNotificationOverlay(),
          ],
        );
      },
    );
  }
}
