import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await integrationDriver(
    responseDataCallback: (data) async {
      await File('docs/qa-report.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      if (data == null) return;
      final adb =
          '${Platform.environment['LOCALAPPDATA']}/Android/Sdk/platform-tools/adb.exe';
      final serial = Platform.environment['CRYSTALO_DEVICE'] ?? 'emulator-5556';
      final base = [
        '-s',
        serial,
        'exec-out',
        'run-as',
        'com.crystalo.crystalo',
      ];
      final folder = data['screenshotsDirectory'] as String;
      final listing = await Process.run(adb, [...base, 'ls', '-1', folder]);
      if (listing.exitCode != 0) {
        throw StateError('Unable to read screenshots: ${listing.stderr}');
      }
      await Directory('docs/screenshots').create(recursive: true);
      for (final name in listing.stdout.toString().trim().split(
        RegExp(r'\s+'),
      )) {
        if (!name.endsWith('.png') || name.contains('/') || name.contains('\\')) {
          continue;
        }
        final result = await Process.run(adb, [
          ...base,
          'cat',
          '$folder/$name',
        ], stdoutEncoding: null);
        if (result.exitCode != 0) throw StateError('Unable to export $name');
        await File('docs/screenshots/$name')
            .writeAsBytes(result.stdout as List<int>);
      }
    },
  );
}
