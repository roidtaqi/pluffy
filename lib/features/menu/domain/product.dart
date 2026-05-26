class CustomizationAddon {
  final String name;
  final double price;

  const CustomizationAddon({required this.name, required this.price});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomizationAddon &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}

class Product {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String categoryId;
  final double rating;
  final bool isSeasonal;
  final bool isPopular;
  final List<String>?
  availableSweetness; // e.g., ['0%', '25%', '50%', '75%', '100%']
  final List<String>? availableIce; // e.g., ['None', 'Less', 'Normal']
  final List<String>? availableTemperature; // e.g., ['Hot', 'Iced']
  final List<CustomizationAddon> availableAddons;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    required this.rating,
    this.isSeasonal = false,
    this.isPopular = false,
    this.availableSweetness,
    this.availableIce,
    this.availableTemperature,
    this.availableAddons = const [],
    this.stock = 10,
  });
}
