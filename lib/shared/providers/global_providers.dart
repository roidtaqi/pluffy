import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../features/outlet/domain/outlet.dart';
import '../../features/menu/domain/product.dart';
import '../data/api_config.dart';
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

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    int? loyaltyPoints,
    int? loyaltyStamps,
    String? membershipTier,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyStamps: loyaltyStamps ?? this.loyaltyStamps,
      membershipTier: membershipTier ?? this.membershipTier,
    );
  }
}

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier() : super(const AsyncValue.data(null));

  String? _authToken;

  UserProfile? get currentUser => state.valueOrNull;

  bool get isAuthenticated => currentUser != null;

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    return _submitAuthRequest(
      endpoint: 'login',
      payload: {'email': email, 'password': password},
    );
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _submitAuthRequest(
      endpoint: 'register',
      payload: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<String?> _submitAuthRequest({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final previousUser = currentUser;
    state = const AsyncValue.loading();

    try {
      final response = await http.post(
        ApiConfig.uri(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        final user = UserProfile.fromJson(body['data']);
        final token = body['token'];
        _authToken = token is String && token.isNotEmpty ? token : null;
        state = AsyncValue.data(user);
        return null;
      }

      state = AsyncValue.data(previousUser);
      return _errorMessageFromBody(body, fallback: 'Authentication failed');
    } catch (err) {
      state = AsyncValue.data(previousUser);
      return 'Tidak bisa terhubung ke server Pluffy. Coba jalankan backend Laravel dulu.';
    }
  }

  Future<String?> updateProfileDetails({
    required String name,
    required String email,
    String? password,
  }) async {
    final user = currentUser;

    if (user == null) {
      return 'Silakan login terlebih dahulu.';
    }

    final previousUser = user;
    state = const AsyncValue.loading();

    final payload = {
      'name': name,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    try {
      final response = await http.put(
        ApiConfig.uri('users/${user.id}'),
        headers: authHeaders,
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (body['success'] == true) {
          final user = UserProfile.fromJson(body['data']);
          state = AsyncValue.data(user);
          return null;
        }
      }

      state = AsyncValue.data(previousUser);
      return _errorMessageFromBody(body, fallback: 'Gagal memperbarui profil.');
    } catch (err) {
      state = AsyncValue.data(previousUser);
      return 'Tidak bisa menyimpan profil karena server tidak merespons.';
    }
  }

  void updateProfile(UserProfile newUser) {
    state = AsyncValue.data(newUser);
  }

  void logout() {
    _authToken = null;
    state = const AsyncValue.data(null);
  }

  String _errorMessageFromBody(dynamic body, {required String fallback}) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }

    return fallback;
  }
}

// Global Provider for User Profile
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      return UserProfileNotifier();
    });

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).valueOrNull != null;
});

// Reactively computed stamps provider (retains compatibility with existing pages)
final loyaltyStampsProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (user) => user?.loyaltyStamps ?? 0,
    orElse: () => 0,
  );
});

// Reactively computed points provider (retains compatibility with existing pages)
final loyaltyPointsProvider = Provider<int>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (user) => user?.loyaltyPoints ?? 0,
    orElse: () => 0,
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
final inAppNotificationProvider = StateProvider<InAppNotification?>(
  (ref) => null,
);

// Provider untuk mengambil produk secara dinamis dari Laravel API
final productsProvider = FutureProvider<List<Product>>((ref) async {
  try {
    final response = await http.get(ApiConfig.uri('products'));

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
            rating: item['rating'] != null
                ? double.parse(item['rating'].toString())
                : 4.8,
            isSeasonal: item['is_seasonal'] == 1 || item['is_seasonal'] == true,
            isPopular:
                item['is_best_seller'] == 1 || item['is_best_seller'] == true,
            availableSweetness: const ['0%', '25%', '50%', '75%', '100%'],
            availableIce: const ['None', 'Less', 'Normal'],
            availableTemperature: const ['Hot', 'Iced'],
            availableAddons: _getAddonsForCategory(item['category']),
            stock: item['stock'] ?? 10,
          );
        }).toList();
      }
    }
  } catch (_) {}

  // Jika gagal terhubung ke backend, gunakan MockData lokal
  return MockData.products;
});

String _mapCategoryToId(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case 'seasonal':
      return 'cat_seasonal';
    case 'soufflé':
    case 'souffle':
      return 'cat_souffle';
    case 'pastry':
      return 'cat_pastry';
    case 'bakery':
      return 'cat_bakery';
    case 'coffee':
      return 'cat_coffee';
    case 'non-coffee':
    case 'noncoffee':
      return 'cat_noncoffee';
    default:
      return 'cat_seasonal';
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
  return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
}
