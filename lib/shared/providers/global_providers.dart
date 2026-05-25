import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/outlet/domain/outlet.dart';
import '../data/mock_data.dart';

// Provider for the currently selected outlet
final activeOutletProvider = StateProvider<Outlet>((ref) {
  return MockData.outlets.first; // Default is Shibuya
});

// Provider for bottom navigation bar index
final navigationIndexProvider = StateProvider<int>((ref) {
  return 0; // Default is Home screen
});

// Provider for user loyalty stamps
final loyaltyStampsProvider = StateNotifierProvider<LoyaltyStampsNotifier, int>((ref) {
  return LoyaltyStampsNotifier();
});

class LoyaltyStampsNotifier extends StateNotifier<int> {
  LoyaltyStampsNotifier() : super(MockData.mockCurrentStamps);

  void addStamps(int count) {
    state = (state + count).clamp(0, MockData.stampsGoal);
  }

  void resetStamps() {
    state = 0;
  }
}

// Provider for user loyalty points
final loyaltyPointsProvider = StateNotifierProvider<LoyaltyPointsNotifier, int>((ref) {
  return LoyaltyPointsNotifier();
});

class LoyaltyPointsNotifier extends StateNotifier<int> {
  LoyaltyPointsNotifier() : super(MockData.mockCurrentPoints);

  void addPoints(int points) {
    state += points;
  }
}

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

