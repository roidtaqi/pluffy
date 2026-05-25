import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../menu/domain/product.dart';
import '../domain/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final String? appliedVoucherCode;
  final double discountPercent; // e.g., 0.15 for 15%
  final double discountFlat;    // e.g., 5.0 for $5.00 off

  const CartState({
    this.items = const [],
    this.appliedVoucherCode,
    this.discountPercent = 0.0,
    this.discountFlat = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount {
    double amt = 0.0;
    if (discountPercent > 0.0) {
      amt += subtotal * discountPercent;
    }
    if (discountFlat > 0.0) {
      amt += discountFlat;
    }
    return amt.clamp(0.0, subtotal);
  }

  double get taxAmount => (subtotal - discountAmount) * 0.10; // Mock 10% Service Tax

  double get serviceFee => subtotal > 0 ? 1.50 : 0.0; // Flat packaging / transaction fee

  double get total => (subtotal - discountAmount + taxAmount + serviceFee).clamp(0.0, double.infinity);

  CartState copyWith({
    List<CartItem>? items,
    String? appliedVoucherCode,
    double? discountPercent,
    double? discountFlat,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedVoucherCode: appliedVoucherCode,
      discountPercent: discountPercent ?? this.discountPercent,
      discountFlat: discountFlat ?? this.discountFlat,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Add item with customizations
  void addItem({
    required Product product,
    int quantity = 1,
    String? selectedSweetness,
    String? selectedIce,
    String? selectedTemperature,
    List<CustomizationAddon> selectedAddons = const [],
  }) {
    final list = List<CartItem>.from(state.items);

    // Look for an existing item with the exact same customizations
    int existingIndex = list.indexWhere((item) {
      if (item.product.id != product.id) return false;
      if (item.selectedSweetness != selectedSweetness) return false;
      if (item.selectedIce != selectedIce) return false;
      if (item.selectedTemperature != selectedTemperature) return false;
      
      // Compare lists of addons
      if (item.selectedAddons.length != selectedAddons.length) return false;
      for (var addon in selectedAddons) {
        if (!item.selectedAddons.contains(addon)) return false;
      }
      return true;
    });

    if (existingIndex >= 0) {
      // Customizations match, increment quantity
      final existing = list[existingIndex];
      list[existingIndex] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      // No match, create new unique cart item
      final newItem = CartItem(
        id: '${product.id}_${DateTime.now().microsecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        selectedSweetness: selectedSweetness,
        selectedIce: selectedIce,
        selectedTemperature: selectedTemperature,
        selectedAddons: selectedAddons,
      );
      list.add(newItem);
    }

    state = state.copyWith(items: list);
  }

  // Update quantity of specific cart item
  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }

    final list = state.items.map((item) {
      return item.id == id ? item.copyWith(quantity: quantity) : item;
    }).toList();

    state = state.copyWith(items: list);
  }

  // Remove specific cart item
  void removeItem(String id) {
    final list = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: list);
  }

  // Apply a voucher code
  bool applyVoucher(String code) {
    final cleanCode = code.trim().toUpperCase();

    if (cleanCode == 'PLUFFY15') {
      state = state.copyWith(
        appliedVoucherCode: 'PLUFFY15',
        discountPercent: 0.15,
        discountFlat: 0.0,
      );
      return true;
    } else if (cleanCode == 'SOUFFLE50') {
      state = state.copyWith(
        appliedVoucherCode: 'SOUFFLE50',
        discountPercent: 0.0,
        discountFlat: 5.00,
      );
      return true;
    } else if (cleanCode == 'SAKURA20') {
      state = state.copyWith(
        appliedVoucherCode: 'SAKURA20',
        discountPercent: 0.20,
        discountFlat: 0.0,
      );
      return true;
    }
    
    return false; // Code invalid
  }

  // Remove active voucher
  void removeVoucher() {
    state = state.copyWith(
      appliedVoucherCode: null,
      discountPercent: 0.0,
      discountFlat: 0.0,
    );
  }

  // Clear cart completely
  void clear() {
    state = const CartState();
  }
}

// Global Provider for Cart State
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
