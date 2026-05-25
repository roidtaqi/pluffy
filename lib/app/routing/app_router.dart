import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/checkout/presentation/order_success_screen.dart';
import '../../features/orders/presentation/order_tracker_screen.dart';
import '../../shared/widgets/splash_screen.dart';
import 'navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/menu',
          pageBuilder: (context, state) => const NoTransitionPage(child: MenuScreen()),
        ),
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) => const NoTransitionPage(child: CartScreen()),
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) => const NoTransitionPage(child: OrdersScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/order-success',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.uri.queryParameters['orderId'] ?? '';
        return OrderSuccessScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order-tracker',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OrderTrackerScreen(),
    ),
  ],
);
