import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../features/outlet/domain/outlet.dart';
import '../../features/menu/domain/product.dart';
import '../data/mock_data.dart';

// Provider for the currently selected outlet
final activeOutletProvider = StateProvider<Outlet>((ref) {
  return MockData.outlets.first; // Default is Shibuya
});

// Provider for bottom navigation bar index
final navigationIndexProvider = StateProvider<int>((ref) {
  return 0; // Default is Home screen
});

// User Profile Data Model
class UserProfile {
  final int id;
  final String name;
  final String email;
  final int loyaltyPoints;
  final int loyaltyStamps;
  final String membershipTier;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.loyaltyPoints,
    required this.loyaltyStamps,
    required this.membershipTier,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      loyaltyPoints: json['loyalty_points'] ?? 0,
      loyaltyStamps: json['loyalty_stamps'] ?? 0,
      membershipTier: json['membership_tier'] ?? 'Bronze Member',
    );
  }
}

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/users/1'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final user = UserProfile.fromJson(body['data']);
          state = AsyncValue.data(user);
          return;
        }
      }
      throw Exception('Failed to load user profile');
    } catch (err) {
      final fallbackUser = UserProfile(
        id: 1,
        name: MockData.userName,
        email: MockData.userEmail,
        loyaltyPoints: MockData.mockCurrentPoints,
        loyaltyStamps: MockData.mockCurrentStamps,
        membershipTier: MockData.membershipTier,
      );
      state = AsyncValue.data(fallbackUser);
    }
  }

  void updateProfile(UserProfile newUser) {
    state = AsyncValue.data(newUser);
  }
}

// Global Provider for User Profile
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return UserProfileNotifier();
});

// Reactively computed stamps provider (retains compatibility with existing pages)
final loyaltyStampsProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (user) => user.loyaltyStamps,
    orElse: () => MockData.mockCurrentStamps,
  );
});

// Reactively computed points provider (retains compatibility with existing pages)
final loyaltyPointsProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (user) => user.loyaltyPoints,
    orElse: () => MockData.mockCurrentPoints,
  );
});

// Model untuk Notifikasi In-App Real-Time
class InAppNotification {
  final String title;
  final String message;
  final String orderId;
  final String statusName;
  final bool isSuccess;

  const InAppNotification({
    required this.title,
    required this.message,
    required this.orderId,
    required this.statusName,
    this.isSuccess = true,
  });
}

// Provider untuk melacak notifikasi aktif
final inAppNotificationProvider = StateProvider<InAppNotification?>((ref) => null);

// Provider untuk mengambil produk secara dinamis dari Laravel API
final productsProvider = FutureProvider<List<Product>>((ref) async {
  try {
    // Di desktop/linux, http://localhost:8000 dapat diakses langsung.
    // Jika di Android Emulator, gunakan http://10.0.2.2:8000
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/products'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List<dynamic> data = body['data'];
        return data.map((item) {
          return Product(
            id: item['id'].toString(),
            name: item['name'],
            description: item['description'],
            basePrice: double.parse(item['base_price'].toString()),
            categoryId: _mapCategoryToId(item['category']),
            rating: item['rating'] != null ? double.parse(item['rating'].toString()) : 4.8,
            isSeasonal: item['is_seasonal'] == 1 || item['is_seasonal'] == true,
            isPopular: item['is_best_seller'] == 1 || item['is_best_seller'] == true,
            availableSweetness: const ['0%', '25%', '50%', '75%', '100%'],
            availableIce: const ['None', 'Less', 'Normal'],
            availableTemperature: const ['Hot', 'Iced'],
            availableAddons: _getAddonsForCategory(item['category']),
            stock: item['stock'] ?? 10,
          );
        }).toList();
      }
    }
  } catch (e) {
    print("Gagal mengambil produk dari Laravel, fallback ke Mock Data: $e");
  }
  
  // Jika gagal terhubung ke backend, gunakan MockData lokal
  return MockData.products;
});

String _mapCategoryToId(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case 'seasonal': return 'cat_seasonal';
    case 'soufflé':
    case 'souffle': return 'cat_souffle';
    case 'pastry': return 'cat_pastry';
    case 'bakery': return 'cat_bakery';
    case 'coffee': return 'cat_coffee';
    case 'non-coffee':
    case 'noncoffee': return 'cat_noncoffee';
    default: return 'cat_seasonal';
  }
}

List<CustomizationAddon> _getAddonsForCategory(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case 'soufflé':
    case 'souffle':
    case 'seasonal':
      return MockData.soufflableAddons;
    case 'coffee':
    case 'non-coffee':
    case 'noncoffee':
      return MockData.drinkAddons;
    default:
      return MockData.bakeryAddons;
  }
}

String formatPrice(double price) {
  if (price >= 1000) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
  }
  return '\$${price.toStringAsFixed(2)}';
}


