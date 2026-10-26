import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crystalo/app.dart';
import 'package:crystalo/data/app_store.dart';

void main() {
  testWidgets('All 50 screen states render at 360dp without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final errors = <String>[];
    for (var id = 1; id <= 50; id++) {
      await tester.pumpWidget(
        CrystaloApp(
          key: ValueKey(id),
          store: AppStore(),
          initialScreen: id,
          autoAdvance: false,
        ),
      );
      await tester.pumpAndSettle();
      final error = tester.takeException();
      if (error != null) errors.add('Screen $id: $error');
    }
    expect(errors, isEmpty);
  });
}
