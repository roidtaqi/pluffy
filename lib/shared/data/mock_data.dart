import '../../features/menu/domain/category.dart';
import '../../features/menu/domain/product.dart';
import '../../features/outlet/domain/outlet.dart';

class MockData {
  MockData._();

  // Outlets
  static const List<Outlet> outlets = [
    Outlet(
      id: 'out_juanda',
      name: 'Pluffy - Juanda Street',
      address: 'Jalan Abdul Muis No. 23, Jakarta (Juanda Plaza)',
      phone: '+81 3-1234-5678',
      operatingHours: '08:00 AM - 10:00 PM',
      distanceKm: 0.4,
    ),
    Outlet(
      id: 'out_ginza',
      name: 'Pluffy - Ginza Corner',
      address: '5-5-1 Ginza, Chuo-ku, Tokyo (Luxury Boulevard)',
      phone: '+81 3-8765-4321',
      operatingHours: '09:00 AM - 09:30 PM',
      distanceKm: 1.2,
    ),
    Outlet(
      id: 'out_harajuku',
      name: 'Pluffy - Harajuku Sweet',
      address: '1-19-8 Jingumae, Shibuya-ku, Tokyo (Takeshita St.)',
      phone: '+81 3-5555-9999',
      operatingHours: '10:00 AM - 09:00 PM',
      distanceKm: 2.5,
    ),
  ];

  // Categories
  static const List<MenuCategory> categories = [
    MenuCategory(id: 'cat_seasonal', name: 'Seasonal', emoji: '🌸'),
    MenuCategory(id: 'cat_souffle', name: 'Soufflé', emoji: '🥞'),
    MenuCategory(id: 'cat_pastry', name: 'Pastry', emoji: '🥐'),
    MenuCategory(id: 'cat_bakery', name: 'Bakery', emoji: '🍞'),
    MenuCategory(id: 'cat_coffee', name: 'Coffee', emoji: '☕'),
    MenuCategory(id: 'cat_noncoffee', name: 'Non-Coffee', emoji: '🍵'),
  ];

  // Common Customization Addons
  static const List<CustomizationAddon> soufflableAddons = [
    CustomizationAddon(name: 'Extra Whipped Cream', price: 1.20),
    CustomizationAddon(name: 'Uji Matcha Ice Cream', price: 2.00),
    CustomizationAddon(name: 'Maple Syrup Drizzle', price: 0.80),
    CustomizationAddon(name: 'Fresh Strawberries', price: 1.50),
  ];

  static const List<CustomizationAddon> drinkAddons = [
    CustomizationAddon(name: 'Brown Sugar Boba', price: 1.20),
    CustomizationAddon(name: 'Extra Espresso Shot', price: 1.00),
    CustomizationAddon(name: 'Oat Milk Swap', price: 0.80),
    CustomizationAddon(name: 'Matcha Cold Foam', price: 1.50),
  ];

  static const List<CustomizationAddon> bakeryAddons = [
    CustomizationAddon(name: 'Premium Butter Spread', price: 0.80),
    CustomizationAddon(name: 'Local Honey Drizzle', price: 1.00),
    CustomizationAddon(name: 'House Chocolate Fudge', price: 1.20),
  ];

  // Products
  static const List<Product> products = [
    // --- SEASONAL FEATURED ---
    Product(
      id: 'prod_mango_souffle',
      name: 'Mango Coco Soufflé Pancake',
      description: 'Summer seasonal soufflé pancake loaded with fresh sweet Alphonso mango cubes, pure coconut cream, and lightly toasted coconut flakes.',
      basePrice: 16.00,
      categoryId: 'cat_seasonal',
      rating: 4.9,
      isSeasonal: true,
      isPopular: true,
      availableSweetness: ['25%', '50%', '75%', '100%'],
      availableAddons: soufflableAddons,
    ),
    Product(
      id: 'prod_sakura_latte',
      name: 'Sakura Lychee White Tea',
      description: 'Delicate organic white tea infused with Japanese cherry blossoms, sweet lychee pulp, served cold with custom peach bubbles.',
      basePrice: 6.80,
      categoryId: 'cat_seasonal',
      rating: 4.7,
      isSeasonal: true,
      availableSweetness: ['50%', '75%', '100%'],
      availableIce: ['None', 'Less', 'Normal'],
      availableTemperature: ['Iced'],
      availableAddons: drinkAddons,
    ),

    // --- SOUFFLE PANCAKES ---
    Product(
      id: 'prod_original_souffle',
      name: 'Original Premium Soufflé',
      description: 'Melt-in-your-mouth award-winning Japanese soufflé pancake served with premium whipped butter, pure maple syrup, and snow sugar dusting.',
      basePrice: 12.50,
      categoryId: 'cat_souffle',
      rating: 4.9,
      isPopular: true,
      availableSweetness: ['50%', '75%', '100%'],
      availableAddons: soufflableAddons,
    ),
    Product(
      id: 'prod_matcha_souffle',
      name: 'Strawberry Uji Matcha Soufflé',
      description: 'Slow-baked soufflé pancake topped with premium Uji Matcha cream, fresh strawberries, and artisanal red bean paste.',
      basePrice: 14.90,
      categoryId: 'cat_souffle',
      rating: 4.8,
      isPopular: true,
      availableSweetness: ['25%', '50%', '75%', '100%'],
      availableAddons: soufflableAddons,
    ),
    Product(
      id: 'prod_brulee_souffle',
      name: 'Boba Crème Brûlée Soufflé',
      description: 'Baked soufflé smothered in rich custard cream, topped with a torched caramelized sugar crust, and served with warm chewy brown sugar boba.',
      basePrice: 15.50,
      categoryId: 'cat_souffle',
      rating: 4.9,
      isPopular: true,
      availableSweetness: ['50%', '75%', '100%'],
      availableAddons: soufflableAddons,
    ),

    // --- PASTRY ---
    Product(
      id: 'prod_peach_croissant',
      name: 'Peach Sweet Custard Croissant',
      description: 'Flaky, buttery multi-layered French croissant generously filled with peach-infused vanilla pastry cream and topped with fresh sliced peaches.',
      basePrice: 5.80,
      categoryId: 'cat_pastry',
      rating: 4.6,
      availableAddons: bakeryAddons,
    ),
    Product(
      id: 'prod_caramel_cruffin',
      name: 'Salted Caramel Pecan Cruffin',
      description: 'Muffin-croissant hybrid rolled in cinnamon sugar, packed with homemade salted caramel filling, and finished with roasted pecan crumbles.',
      basePrice: 6.20,
      categoryId: 'cat_pastry',
      rating: 4.7,
      isPopular: true,
      availableAddons: bakeryAddons,
    ),

    // --- BAKERY ---
    Product(
      id: 'prod_milk_bread',
      name: 'Hokkaido Milk Bread Loaf',
      description: 'Super pillowy, tender, and slightly sweet Japanese Shokupan loaf, baked fresh daily with organic milk. Perfect for sharing.',
      basePrice: 8.00,
      categoryId: 'cat_bakery',
      rating: 4.8,
      availableAddons: bakeryAddons,
    ),
    Product(
      id: 'prod_matcha_melonpan',
      name: 'Uji Matcha Cream Melonpan',
      description: 'Traditional Japanese sweet bread covered in a crispy matcha cookie shell, sliced open and stuffed with a velvety matcha milk cream.',
      basePrice: 4.50,
      categoryId: 'cat_bakery',
      rating: 4.7,
      availableAddons: bakeryAddons,
    ),

    // --- COFFEE ---
    Product(
      id: 'prod_peach_matcha_coffee',
      name: 'Peach Matcha Cloud Cold Brew',
      description: 'Premium slow-steeped cold brew coffee crowned with a rich, layered head of peach matcha cold foam. A refreshing sweet contrast.',
      basePrice: 6.50,
      categoryId: 'cat_coffee',
      rating: 4.8,
      isPopular: true,
      availableSweetness: ['0%', '25%', '50%', '75%', '100%'],
      availableIce: ['None', 'Less', 'Normal'],
      availableTemperature: ['Iced'],
      availableAddons: drinkAddons,
    ),
    Product(
      id: 'prod_cacao_mocha',
      name: 'Cacao Dark Mocha Latte',
      description: 'Double espresso shots whisked with artisanal dark cocoa powder, streamed organic oat milk, and a dusting of grated cacao nibs.',
      basePrice: 6.00,
      categoryId: 'cat_coffee',
      rating: 4.6,
      availableSweetness: ['25%', '50%', '75%', '100%'],
      availableIce: ['None', 'Less', 'Normal'],
      availableTemperature: ['Hot', 'Iced'],
      availableAddons: drinkAddons,
    ),

    // --- NON-COFFEE ---
    Product(
      id: 'prod_hojicha_latte',
      name: 'Roasted Hojicha Honey Latte',
      description: 'Slow-roasted nutty green tea powder whisked with organic milk and raw wild honey, producing a comforting smoky sweetness.',
      basePrice: 6.20,
      categoryId: 'cat_noncoffee',
      rating: 4.9,
      isPopular: true,
      availableSweetness: ['0%', '25%', '50%', '75%', '100%'],
      availableIce: ['None', 'Less', 'Normal'],
      availableTemperature: ['Hot', 'Iced'],
      availableAddons: drinkAddons,
    ),
  ];

  // Loyalty Card stamps requirement
  static const int stampsGoal = 10;
  static const int mockCurrentStamps = 6;
  static const int mockCurrentPoints = 640;

  // Active Promo banners
  static const List<Map<String, String>> promoBanners = [
    {
      'title': 'Seasonal Sakura Special',
      'description': 'Enjoy 20% off all Lychee White Tea combinations this spring season!',
      'code': 'SAKURA20',
      'image': '🌸',
    },
    {
      'title': 'Soufflé Happy Hours',
      'description': 'Buy 1 Original Soufflé and get a free beverage of your choice. Mon-Fri 2PM-5PM.',
      'code': 'SOUFFLELOVE',
      'image': '🥞',
    },
    {
      'title': 'Gold Member Reward',
      'description': 'Thank you for 600+ points! Claim a free Melonpan on your next checkout.',
      'code': 'GOLDFREE',
      'image': '✨',
    }
  ];

  // Mock profile details
  static const String userName = 'Chloe Henderson';
  static const String userEmail = 'chloe.henderson@example.com';
  static const String userPhone = '+81 90-8888-7777';
  static const String membershipTier = 'Gold Member';
}
