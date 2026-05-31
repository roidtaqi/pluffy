import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/auth_session_storage_backend.dart';
import '../../../shared/providers/global_providers.dart';

enum SavedPaymentMethodType { wallet, card, digitalWallet }

class SavedPaymentMethod {
  final String id;
  final String title;
  final String subtitle;
  final SavedPaymentMethodType type;
  final bool isDefault;
  final bool canRemove;

  const SavedPaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isDefault = false,
    this.canRemove = false,
  });

  SavedPaymentMethod copyWith({bool? isDefault}) {
    return SavedPaymentMethod(
      id: id,
      title: title,
      subtitle: subtitle,
      type: type,
      isDefault: isDefault ?? this.isDefault,
      canRemove: canRemove,
    );
  }

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethod(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: SavedPaymentMethodType.values.byName(json['type']),
      isDefault: json['is_default'] ?? false,
      canRemove: json['can_remove'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'is_default': isDefault,
      'can_remove': canRemove,
    };
  }
}

class SavedAddress {
  final String id;
  final String label;
  final String address;
  final String notes;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.notes,
    this.isDefault = false,
  });

  SavedAddress copyWith({bool? isDefault}) {
    return SavedAddress(
      id: id,
      label: label,
      address: address,
      notes: notes,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'],
      label: json['label'],
      address: json['address'],
      notes: json['notes'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'notes': notes,
      'is_default': isDefault,
    };
  }
}

class ProfilePreferencesState {
  final List<SavedPaymentMethod> paymentMethods;
  final List<SavedAddress> addresses;

  const ProfilePreferencesState({
    required this.paymentMethods,
    required this.addresses,
  });

  factory ProfilePreferencesState.initial() {
    return const ProfilePreferencesState(
      paymentMethods: [
        SavedPaymentMethod(
          id: 'wallet',
          title: 'Pluffy Pay',
          subtitle: 'Saldo: Rp 500.000',
          type: SavedPaymentMethodType.wallet,
          isDefault: true,
        ),
        SavedPaymentMethod(
          id: 'card_visa_4321',
          title: 'Kartu Visa **** 4321',
          subtitle: 'Kartu debit atau kredit tersimpan',
          type: SavedPaymentMethodType.card,
          canRemove: true,
        ),
        SavedPaymentMethod(
          id: 'gpay',
          title: 'Google Pay',
          subtitle: 'Pembayaran digital cepat dan aman',
          type: SavedPaymentMethodType.digitalWallet,
        ),
      ],
      addresses: [],
    );
  }

  SavedPaymentMethod get defaultPaymentMethod {
    return paymentMethods.firstWhere(
      (method) => method.isDefault,
      orElse: () => paymentMethods.first,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_methods': paymentMethods.map((item) => item.toJson()).toList(),
      'addresses': addresses.map((item) => item.toJson()).toList(),
    };
  }
}

class ProfilePreferencesNotifier
    extends StateNotifier<ProfilePreferencesState> {
  final int? _userId;
  final AuthSessionStorageBackend _storage;
  Future<void> _saveQueue = Future<void>.value();
  bool _hasLocalChanges = false;

  ProfilePreferencesNotifier({
    required this._userId,
    AuthSessionStorageBackend? storage,
  }) : _storage = storage ?? createAuthSessionStorageBackend(),
       super(ProfilePreferencesState.initial()) {
    unawaited(_restore());
  }

  String? get _storageKey {
    final userId = _userId;
    return userId == null ? null : 'pluffy_profile_preferences_$userId';
  }

  void setDefaultPaymentMethod(String id) {
    if (!state.paymentMethods.any((method) => method.id == id)) return;

    state = ProfilePreferencesState(
      paymentMethods: [
        for (final method in state.paymentMethods)
          method.copyWith(isDefault: method.id == id),
      ],
      addresses: state.addresses,
    );
    _save();
  }

  void addCard({required String holderName, required String cardNumber}) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return;
    final lastFour = digits.substring(digits.length - 4);
    final id = 'card_${DateTime.now().microsecondsSinceEpoch}';

    state = ProfilePreferencesState(
      paymentMethods: [
        ...state.paymentMethods,
        SavedPaymentMethod(
          id: id,
          title: 'Kartu **** $lastFour',
          subtitle: 'Atas nama $holderName',
          type: SavedPaymentMethodType.card,
          canRemove: true,
        ),
      ],
      addresses: state.addresses,
    );
    _save();
  }

  void removePaymentMethod(String id) {
    final method = state.paymentMethods
        .where((item) => item.id == id)
        .firstOrNull;
    if (method == null || !method.canRemove) return;

    final remaining = state.paymentMethods
        .where((item) => item.id != id)
        .toList();
    if (method.isDefault && remaining.isNotEmpty) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }

    state = ProfilePreferencesState(
      paymentMethods: remaining,
      addresses: state.addresses,
    );
    _save();
  }

  void addAddress({
    required String label,
    required String address,
    required String notes,
  }) {
    final isFirstAddress = state.addresses.isEmpty;
    state = ProfilePreferencesState(
      paymentMethods: state.paymentMethods,
      addresses: [
        ...state.addresses,
        SavedAddress(
          id: 'address_${DateTime.now().microsecondsSinceEpoch}',
          label: label,
          address: address,
          notes: notes,
          isDefault: isFirstAddress,
        ),
      ],
    );
    _save();
  }

  void setDefaultAddress(String id) {
    if (!state.addresses.any((address) => address.id == id)) return;

    state = ProfilePreferencesState(
      paymentMethods: state.paymentMethods,
      addresses: [
        for (final address in state.addresses)
          address.copyWith(isDefault: address.id == id),
      ],
    );
    _save();
  }

  void removeAddress(String id) {
    final address = state.addresses.where((item) => item.id == id).firstOrNull;
    if (address == null) return;

    final remaining = state.addresses.where((item) => item.id != id).toList();
    if (address.isDefault && remaining.isNotEmpty) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }

    state = ProfilePreferencesState(
      paymentMethods: state.paymentMethods,
      addresses: remaining,
    );
    _save();
  }

  Future<void> _restore() async {
    final storageKey = _storageKey;
    if (storageKey == null) return;

    try {
      final encoded = await _storage.read(key: storageKey);
      if (encoded == null) return;

      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) return;

      final paymentMethods = (decoded['payment_methods'] as List<dynamic>)
          .map(
            (item) => SavedPaymentMethod.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      final addresses = (decoded['addresses'] as List<dynamic>)
          .map((item) => SavedAddress.fromJson(item as Map<String, dynamic>))
          .toList();

      if (paymentMethods.isEmpty) return;
      if (_hasLocalChanges) return;
      state = ProfilePreferencesState(
        paymentMethods: paymentMethods,
        addresses: addresses,
      );
    } catch (_) {}
  }

  void _save() {
    final storageKey = _storageKey;
    if (storageKey == null) return;
    _hasLocalChanges = true;
    final encodedState = jsonEncode(state.toJson());
    _saveQueue = _saveQueue
        .then((_) => _storage.write(key: storageKey, value: encodedState))
        .catchError((_) {});
  }
}

final profilePreferencesProvider =
    StateNotifierProvider<ProfilePreferencesNotifier, ProfilePreferencesState>((
      ref,
    ) {
      final userId = ref.watch(userProfileProvider).valueOrNull?.id;
      return ProfilePreferencesNotifier(userId: userId);
    });
