import '../../menu/domain/product.dart';

class CartItem {
  final String
  id; // Unique cart item ID (in case the same product is added with different customizations)
  final Product product;
  final int quantity;
  final String? selectedSweetness;
  final String? selectedIce;
  final String? selectedTemperature;
  final List<CustomizationAddon> selectedAddons;

  const CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSweetness,
    this.selectedIce,
    this.selectedTemperature,
    this.selectedAddons = const [],
  });

  // Calculate price of the single item with customizations
  double get unitPrice {
    double addonsTotal = selectedAddons.fold(
      0.0,
      (sum, item) => sum + item.price,
    );
    return product.basePrice + addonsTotal;
  }

  // Calculate total price for this cart row (unitPrice * quantity)
  double get totalPrice {
    return unitPrice * quantity;
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSweetness,
    String? selectedIce,
    String? selectedTemperature,
    List<CustomizationAddon>? selectedAddons,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSweetness: selectedSweetness ?? this.selectedSweetness,
      selectedIce: selectedIce ?? this.selectedIce,
      selectedTemperature: selectedTemperature ?? this.selectedTemperature,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }
}
