// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final vmUrl = "http://127.0.0.1:40693/m9K3Pyvuk58=/";
  final isolateId = "isolates/294855672581191";

  print("Querying libraries for isolate $isolateId...");
  final client = HttpClient();

  try {
    // 1. Get Isolate details
    final uri = Uri.parse("${vmUrl}getIsolate?isolateId=$isolateId");
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body);

    if (data['error'] != null) {
      print("Error getting isolate: ${data['error']}");
      return;
    }

    final libraries = data['result']['libraries'] as List;
    print("Found ${libraries.length} libraries.");

    // Find our specific libraries
    final pluffyLibs = libraries.where((lib) {
      final uri = lib['uri'] as String;
      return uri.startsWith("package:pluffy/");
    }).toList();

    print("\nPluffy Application Libraries:");
    for (var lib in pluffyLibs) {
      print("- ${lib['uri']} (ID: ${lib['id']})");
    }

    // Let's find orders_repository.dart
    final repoLib = pluffyLibs.firstWhere(
      (lib) => (lib['uri'] as String).contains("orders_repository.dart"),
      orElse: () => null,
    );

    if (repoLib == null) {
      print("\nCould not find orders_repository.dart library!");
      return;
    }

    print("\nEvaluating state in ${repoLib['uri']}...");

    // Send JSON-RPC evaluate to the root endpoint
    final evalReq = await client.postUrl(Uri.parse(vmUrl));
    evalReq.headers.contentType = ContentType.json;
    evalReq.write(
      jsonEncode({
        "jsonrpc": "2.0",
        "method": "evaluate",
        "params": {
          "isolateId": isolateId,
          "targetId": repoLib['id'],
          "expression": "ordersProvider.toString()",
        },
        "id": "eval1",
      }),
    );

    final evalRes = await evalReq.close();
    final evalBody = await evalRes.transform(utf8.decoder).join();
    print("Evaluation result:\n$evalBody");
  } catch (e) {
    print("Error: $e");
  } finally {
    client.close();
  }
}
