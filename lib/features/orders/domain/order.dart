import '../../cart/domain/cart_item.dart';

enum OrderStatus { placed, preparing, ready, completed }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'In the Kitchen';
      case OrderStatus.ready:
        return 'Ready at Counter';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.placed:
        return 'We have received your order and are processing it.';
      case OrderStatus.preparing:
        return 'Our chefs are crafting your fluffy delicacies with love.';
      case OrderStatus.ready:
        return 'Your warm dessert is ready! Head over to the counter.';
      case OrderStatus.completed:
        return 'Thank you for dining with Pluffy! Hope to see you soon.';
    }
  }
}

class OrderModel {
  final String id;
  final DateTime orderDate;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double serviceFee;
  final double total;
  final OrderStatus status;
  final String outletName;
  final String paymentMethod;
  final String? voucherCode;

  const OrderModel({
    required this.id,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.serviceFee,
    required this.total,
    required this.status,
    required this.outletName,
    required this.paymentMethod,
    this.voucherCode,
  });

  OrderModel copyWith({
    String? id,
    DateTime? orderDate,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? serviceFee,
    double? total,
    OrderStatus? status,
    String? outletName,
    String? paymentMethod,
    String? voucherCode,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      serviceFee: serviceFee ?? this.serviceFee,
      total: total ?? this.total,
      status: status ?? this.status,
      outletName: outletName ?? this.outletName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      voucherCode: voucherCode ?? this.voucherCode,
    );
  }
}
