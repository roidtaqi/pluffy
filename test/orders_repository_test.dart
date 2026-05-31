import 'package:flutter_test/flutter_test.dart';
import 'package:pluffy/features/orders/data/orders_repository.dart';

void main() {
  group('readyPickupNotificationMessage', () {
    test('uses the outlet stored on the selected order', () {
      final message = readyPickupNotificationMessage(
        orderId: 'ORD-PELITA-1',
        outletName: 'Pluffy - Pelita Square',
      );

      expect(message, contains('konter Pelita Square'));
      expect(message, contains('ORD-PELITA-1'));
      expect(message, isNot(contains('Shibuya')));
    });

    test('uses a neutral fallback when an outlet is unavailable', () {
      final message = readyPickupNotificationMessage(orderId: 'ORD-LOCAL-1');

      expect(message, contains('konter outlet pilihan Anda'));
      expect(message, contains('ORD-LOCAL-1'));
    });
  });
}
