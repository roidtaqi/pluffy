import 'package:flutter/foundation.dart';

import 'orders_repository.dart';

class AdminWebServer {
  final OrdersNotifier notifier;
  final int port;

  AdminWebServer({required this.notifier, required this.port});

  Future<void> start() async {
    // No-op or log on web platforms
    debugPrint('Admin Web Server is disabled on Flutter Web platform.');
  }

  void stop() {
    // No-op on web platforms
  }
}
