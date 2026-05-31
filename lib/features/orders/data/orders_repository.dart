import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/providers/global_providers.dart';
import '../../../shared/data/api_config.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/order.dart';
import 'admin_web_server.dart';

String readyPickupNotificationMessage({
  required String orderId,
  String? outletName,
}) {
  final pickupCounter = outletName?.replaceFirst('Pluffy - ', '').trim();
  final counterLabel = pickupCounter == null || pickupCounter.isEmpty
      ? 'outlet pilihan Anda'
      : pickupCounter;

  return 'Silakan menuju konter $counterLabel. '
      'Tunjukkan ID pesanan: $orderId!';
}

class OrdersState {
  final List<OrderModel> orders;
  final OrderModel? activeOrder; // Currently tracking order
  final bool autoSimulate;
  final int serverPort;

  const OrdersState({
    this.orders = const [],
    this.activeOrder,
    this.autoSimulate = false,
    this.serverPort = 8080,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    OrderModel? activeOrder,
    bool clearActiveOrder = false,
    bool? autoSimulate,
    int? serverPort,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      activeOrder: clearActiveOrder ? null : activeOrder ?? this.activeOrder,
      autoSimulate: autoSimulate ?? this.autoSimulate,
      serverPort: serverPort ?? this.serverPort,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final Ref _ref;
  Timer? _statusTimer;
  Timer? _backendRefreshTimer;
  AdminWebServer? _webServer;

  OrdersState get currentState => state;

  OrdersNotifier(this._ref) : super(const OrdersState()) {
    // Populate some initial mock order history
    _loadMockHistory();
    // Start local web server
    _startWebServer();
  }

  void _loadMockHistory() {
    final now = DateTime.now();
    state = state.copyWith(
      orders: [
        OrderModel(
          id: 'ORD-9821-H',
          orderDate: now.subtract(const Duration(days: 3)),
          items: [], // Simplified historical list
          subtotal: 25.00,
          discount: 0.0,
          tax: 2.50,
          serviceFee: 1.50,
          total: 29.00,
          status: OrderStatus.completed,
          outletName: 'Pluffy - Shibuya Main',
          paymentMethod: 'Credit Card (VISA)',
        ),
        OrderModel(
          id: 'ORD-4491-K',
          orderDate: now.subtract(const Duration(days: 7)),
          items: [],
          subtotal: 18.70,
          discount: 2.80,
          tax: 1.59,
          serviceFee: 1.50,
          total: 18.99,
          status: OrderStatus.completed,
          outletName: 'Pluffy - Harajuku Sweet',
          paymentMethod: 'Pluffy Pay Wallet',
          voucherCode: 'PLUFFY15',
        ),
      ],
    );
  }

  // Start the internal Web Admin local server
  Future<void> _startWebServer() async {
    try {
      _webServer = AdminWebServer(notifier: this, port: 8080);
      await _webServer!.start();
      state = state.copyWith(serverPort: _webServer!.port);
    } catch (e) {
      // In case 8080 is taken, try a different port (e.g. 8081)
      try {
        _webServer = AdminWebServer(notifier: this, port: 8081);
        await _webServer!.start();
        state = state.copyWith(serverPort: _webServer!.port);
      } catch (e) {
        debugPrint('Failed to start Pluffy Web Admin Server: $e');
      }
    }
  }

  // Create a new order from active checkout details
  Future<String> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double serviceFee,
    required double total,
    required String outletName,
    required String paymentMethod,
    required int userId,
    String? voucherCode,
  }) async {
    final orderId =
        'ORD-${1000 + state.orders.length + 1}-${DateTime.now().millisecond}';

    try {
      // Backend products use numeric IDs. Mock fallback products use string IDs,
      // so parsing belongs inside this guarded backend path.
      final itemsPayload = items.map((item) {
        return {
          'product_id': int.parse(item.product.id),
          'quantity': item.quantity,
          'price': item.product.basePrice.toInt(),
        };
      }).toList();

      final payload = {
        'subtotal': subtotal.toInt(),
        'discount': discount.toInt(),
        'tax': tax.toInt(),
        'service_fee': serviceFee.toInt(),
        'total': total.toInt(),
        'outlet_name': outletName,
        'payment_method': paymentMethod,
        'voucher_code': voucherCode,
        'user_id': userId,
        'items': itemsPayload,
      };

      final response = await http.post(
        ApiConfig.uri('orders'),
        headers: _ref.read(userProfileProvider.notifier).authHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'];
          final serverOrderId = data['order_id'];
          final userData = data['user'];

          final newOrder = OrderModel(
            id: serverOrderId,
            orderDate: DateTime.now(),
            items: items,
            subtotal: subtotal,
            discount: discount,
            tax: tax,
            serviceFee: serviceFee,
            total: total,
            status: OrderStatus.placed,
            outletName: outletName,
            paymentMethod: paymentMethod,
            voucherCode: voucherCode,
          );

          // Update local orders list
          state = state.copyWith(
            orders: [newOrder, ...state.orders],
            activeOrder: newOrder,
          );
          _startBackendStatusSync();

          // Update user profile dynamically in global provider
          final currentUser = _ref.read(userProfileProvider).valueOrNull;
          if (currentUser != null) {
            final updatedUser = UserProfile(
              id: currentUser.id,
              name: currentUser.name,
              email: currentUser.email,
              loyaltyPoints:
                  userData['loyalty_points'] ?? currentUser.loyaltyPoints,
              loyaltyStamps:
                  userData['loyalty_stamps'] ?? currentUser.loyaltyStamps,
              membershipTier:
                  userData['membership_tier'] ?? currentUser.membershipTier,
            );
            _ref.read(userProfileProvider.notifier).updateProfile(updatedUser);
          }

          // Trigger dynamic re-fetching of products list to update stocks live!
          _ref.invalidate(productsProvider);

          return serverOrderId;
        }
      }
    } catch (e) {
      debugPrint('Failed to post order to Laravel backend: $e');
    }

    // Fallback: local in-memory order placement if server fails
    final newOrder = OrderModel(
      id: orderId,
      orderDate: DateTime.now(),
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      serviceFee: serviceFee,
      total: total,
      status: OrderStatus.placed,
      outletName: outletName,
      paymentMethod: paymentMethod,
      voucherCode: voucherCode,
    );

    // Cancel any existing status simulation timer
    _statusTimer?.cancel();

    state = state.copyWith(
      orders: [newOrder, ...state.orders],
      activeOrder: newOrder,
    );
    _startBackendStatusSync();

    // Start status progression simulator if auto-simulation is enabled
    if (state.autoSimulate) {
      _startStatusSimulation();
    }

    return orderId;
  }

  // Reorder a past order by extracting items
  List<CartItem> getItemsFromPastOrder(String orderId) {
    final order = state.orders.firstWhere((o) => o.id == orderId);
    return order.items;
  }

  // Toggle auto-simulation from Admin Web or settings
  void toggleAutoSimulate(bool value) {
    state = state.copyWith(autoSimulate: value);
    if (value) {
      _startStatusSimulation();
    } else {
      _statusTimer?.cancel();
    }
  }

  // Manually update the status of any order (e.g. via Web Admin or simulation)
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final updatedOrders = state.orders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: newStatus);
      }
      return o;
    }).toList();

    OrderModel? activeOrder = state.activeOrder;
    if (activeOrder != null && activeOrder.id == orderId) {
      activeOrder = activeOrder.copyWith(status: newStatus);
      if (newStatus == OrderStatus.completed) {
        activeOrder = null;
      }
    }

    state = state.copyWith(
      orders: updatedOrders,
      activeOrder: activeOrder,
      clearActiveOrder: newStatus == OrderStatus.completed,
    );

    if (newStatus == OrderStatus.completed) {
      _stopBackendStatusSync();
    } else if (activeOrder != null) {
      _startBackendStatusSync();
    }

    // Trigger local notification so customer receives it
    _triggerNotificationForStatus(orderId, newStatus);
  }

  void _startBackendStatusSync() {
    if (_backendRefreshTimer != null) return;

    refreshActiveOrderFromBackend();
    _backendRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshActiveOrderFromBackend();
    });
  }

  void _stopBackendStatusSync() {
    _backendRefreshTimer?.cancel();
    _backendRefreshTimer = null;
  }

  Future<void> refreshActiveOrderFromBackend() async {
    final activeOrder = state.activeOrder;
    if (activeOrder == null) {
      _stopBackendStatusSync();
      return;
    }

    try {
      final response = await http.get(
        ApiConfig.uri('orders'),
        headers: _ref.read(userProfileProvider.notifier).authHeaders,
      );
      if (response.statusCode != 200) return;

      final Map<String, dynamic> body = jsonDecode(response.body);
      final orders = body['orders'];
      if (orders is! List) return;

      Map<String, dynamic>? remoteOrder;
      for (final order in orders) {
        if (order is Map<String, dynamic> && order['id'] == activeOrder.id) {
          remoteOrder = order;
          break;
        }
      }

      final statusName = remoteOrder?['status'];
      if (statusName is! String) return;

      OrderStatus? remoteStatus;
      for (final status in OrderStatus.values) {
        if (status.name == statusName) {
          remoteStatus = status;
          break;
        }
      }

      if (remoteStatus != null && remoteStatus != activeOrder.status) {
        updateOrderStatus(activeOrder.id, remoteStatus);
      }
    } catch (_) {}
  }

  // Trigger global in-app notification state for real-time customer popups
  void _triggerNotificationForStatus(String orderId, OrderStatus status) {
    String title = "";
    String message = "";
    String? outletName;

    for (final order in state.orders) {
      if (order.id == orderId) {
        outletName = order.outletName;
        break;
      }
    }

    switch (status) {
      case OrderStatus.placed:
        title = "Order Placed! 🥞";
        message = "We have received your order and payment successfully.";
        break;
      case OrderStatus.preparing:
        title = "In the Kitchen! 🍳";
        message =
            "Pluffy koki sedang memanggang soufflé lezat Anda dengan cinta!";
        break;
      case OrderStatus.ready:
        title = "Hidangan Siap Diambil! 🥞🎉";
        message = readyPickupNotificationMessage(
          orderId: orderId,
          outletName: outletName,
        );
        break;
      case OrderStatus.completed:
        title = "Pesanan Selesai! ❤️";
        message =
            "Terima kasih telah berkunjung ke Pluffy! Selamat menikmati hidangan hangat Anda.";
        break;
    }

    _ref.read(inAppNotificationProvider.notifier).state = InAppNotification(
      title: title,
      message: message,
      orderId: orderId,
      statusName: status.displayName,
    );
  }

  // Simulate kitchen progress transitions for the active order
  void _startStatusSimulation() {
    _statusTimer?.cancel();
    int currentStep = 0;

    if (state.activeOrder != null) {
      currentStep = state.activeOrder!.status.index;
    }

    _statusTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (state.activeOrder == null || !state.autoSimulate) {
        timer.cancel();
        return;
      }

      currentStep++;
      OrderStatus nextStatus;

      if (currentStep == 1) {
        nextStatus = OrderStatus.preparing;
      } else if (currentStep == 2) {
        nextStatus = OrderStatus.ready;
      } else {
        nextStatus = OrderStatus.completed;
        timer.cancel();
      }

      updateOrderStatus(state.activeOrder!.id, nextStatus);
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _backendRefreshTimer?.cancel();
    _webServer?.stop();
    super.dispose();
  }
}

// Global Provider for Orders
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((
  ref,
) {
  return OrdersNotifier(ref);
});
