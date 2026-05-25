import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../../admin/data/admin_web_content.dart';
import '../domain/order.dart';
import 'orders_repository.dart';

class AdminWebServer {
  final OrdersNotifier notifier;
  final int port;
  HttpServer? _server;

  AdminWebServer({
    required this.notifier,
    required this.port,
  });

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print("Pluffy Admin Web Server running on http://localhost:$port/admin");

    _server!.listen((HttpRequest request) async {
      // Handle CORS Preflight (OPTIONS)
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
        return;
      }

      final uri = request.uri.path;

      try {
        if (uri == '/admin') {
          // Serve Admin Web App HTML
          request.response.headers.contentType = ContentType.html;
          request.response.write(AdminWebContent.html);
          await request.response.close();
        } else if (uri == '/api/logo') {
          // Serve Custom PNG Logo
          final byteData = await rootBundle.load('assets/images/logo.png');
          final bytes = byteData.buffer.asUint8List();
          request.response.headers.contentType = ContentType.parse('image/png');
          request.response.add(bytes);
          await request.response.close();
        } else if (uri == '/api/orders') {
          // Serve orders JSON list
          final orders = notifier.currentState.orders.map((o) {
            return {
              'id': o.id,
              'orderDate': o.orderDate.toIso8601String(),
              'outletName': o.outletName,
              'total': o.total,
              'status': o.status.name, // placed, preparing, ready, completed
              'items': o.items.map((item) {
                return {
                  'productName': item.product.name,
                  'quantity': item.quantity,
                  'price': item.unitPrice,
                };
              }).toList(),
            };
          }).toList();

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'orders': orders}));
          await request.response.close();
        } else if (uri == '/api/simulation') {
          // Get current simulation state
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'autoSimulate': notifier.currentState.autoSimulate}));
          await request.response.close();
        } else if (uri == '/api/simulation/toggle' && request.method == 'POST') {
          // Toggle simulation state
          final body = await utf8.decoder.bind(request).join();
          final data = jsonDecode(body);
          final bool autoSim = data['autoSimulate'] ?? true;
          
          notifier.toggleAutoSimulate(autoSim);

          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'success': true}));
          await request.response.close();
        } else if (uri == '/api/orders/update' && request.method == 'POST') {
          // Update order status
          final body = await utf8.decoder.bind(request).join();
          final data = jsonDecode(body);
          final String orderId = data['id'];
          final String statusStr = data['status'];

          OrderStatus? newStatus;
          for (var s in OrderStatus.values) {
            if (s.name == statusStr) {
              newStatus = s;
              break;
            }
          }

          if (newStatus != null) {
            notifier.updateOrderStatus(orderId, newStatus);
            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } else {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'error': 'Invalid status'}));
          }
          await request.response.close();
        } else {
          // 404 Not Found
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('Not Found');
          await request.response.close();
        }
      } catch (e) {
        print("Error serving HTTP request: $e");
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write(jsonEncode({'error': e.toString()}));
          await request.response.close();
        } catch (_) {}
      }
    });
  }

  void stop() {
    _server?.close(force: true);
  }
}
