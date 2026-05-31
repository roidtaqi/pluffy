import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pluffy/features/profile/data/profile_preferences.dart';
import 'package:pluffy/shared/data/auth_session_storage_backend.dart';

void main() {
  test(
    'profile preferences persist payment methods and addresses per user',
    () async {
      final storage = _MemoryStorageBackend();
      final notifier = ProfilePreferencesNotifier(userId: 7, storage: storage);

      notifier.setDefaultPaymentMethod('card_visa_4321');
      notifier.addCard(holderName: 'Roid', cardNumber: '1234 5678 1234 9999');
      notifier.addAddress(
        label: 'Rumah',
        address: 'Jalan Pelita No. 10',
        notes: 'Pagar merah',
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final encoded = storage.values['pluffy_profile_preferences_7'];
      expect(encoded, isNotNull);
      expect(encoded, isNot(contains('1234 5678 1234 9999')));
      expect(encoded, contains('9999'));

      final restored = ProfilePreferencesNotifier(userId: 7, storage: storage);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(restored.state.defaultPaymentMethod.id, 'card_visa_4321');
      expect(restored.state.paymentMethods.last.title, 'Kartu **** 9999');
      expect(restored.state.addresses.single.label, 'Rumah');
      expect(restored.state.addresses.single.isDefault, isTrue);

      notifier.dispose();
      restored.dispose();
    },
  );
}

class _MemoryStorageBackend implements AuthSessionStorageBackend {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    jsonDecode(value);
    values[key] = value;
  }
}
