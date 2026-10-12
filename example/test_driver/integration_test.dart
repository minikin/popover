import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      final screenshots =
          (data?['screenshots'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      final dir = Directory('build/screenshots')..createSync(recursive: true);
      for (final MapEntry(key: name, value: png) in screenshots.entries) {
        File('${dir.path}/$name.png')
            .writeAsBytesSync(base64Decode(png as String));
      }
    },
  );
}
