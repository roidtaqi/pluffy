import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/order.dart';

class OrdersState {
  final List<OrderModel> orders;
  final OrderModel? activeOrder; // Currently tracking order

  const OrdersState({
    this.orders = const [],
    this.activeOrder,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    OrderModel? activeOrder,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      activeOrder: activeOrder, // Can set to null
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  Timer? _statusTimer;

  OrdersNotifier() : super(const OrdersState()) {
    // Populate some initial mock order history
    _loadMockHistory();
  }

  void _loadMockHistory() {
    final now = DateTime.now();
    state = OrdersState(
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

  // Create a new order from active checkout details
  String placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double serviceFee,
    required double total,
    required String outletName,
    required String paymentMethod,
    String? voucherCode,
  }) {
    final orderId = 'ORD-${1000 + state.orders.length + 1}-${DateTime.now().millisecond}';
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

    // Start status progression simulator
    _startStatusSimulation();

    return orderId;
  }

  // Reorder a past order by extracting items
  List<CartItem> getItemsFromPastOrder(String orderId) {
    final order = state.orders.firstWhere((o) => o.id == orderId);
    return order.items;
  }

  // Simulate kitchen progress transitions for the active order
  void _startStatusSimulation() {
    int currentStep = 0;
    
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (state.activeOrder == null) {
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

      final updatedOrder = state.activeOrder!.copyWith(status: nextStatus);
      
      // Update active order and replace it in the orders list
      final updatedOrdersList = state.orders.map((o) {
        return o.id == updatedOrder.id ? updatedOrder : o;
      }).toList();

      state = OrdersState(
        orders: updatedOrdersList,
        activeOrder: nextStatus == OrderStatus.completed ? null : updatedOrder, // Clear active when fully done
      );
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}

// Global Provider for Orders
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier();
});
