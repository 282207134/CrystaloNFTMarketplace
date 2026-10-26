import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:crystalo/app.dart';
import 'package:crystalo/data/app_store.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture 50 Pixso states and exercise the main user journeys', (
    tester,
  ) async {
    final store = AppStore();
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      CrystaloApp(
        store: store,
        navigatorKey: navigator,
        initialScreen: 5,
        autoAdvance: false,
      ),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    final directory = Directory(
      '${Directory.systemTemp.path}/crystalo-screens',
    );
    await directory.create(recursive: true);
    Future<void> open(int id) async {
      FocusManager.instance.primaryFocus?.unfocus();
      navigator.currentState!.pushNamedAndRemoveUntil(
        '/screen/$id',
        (_) => false,
      );
      await tester.pumpAndSettle();
    }

    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 650));
      await tester.pump();
      final bytes = await binding.takeScreenshot(name);
      await File('${directory.path}/$name.png').writeAsBytes(bytes);
      binding.reportData?.remove('screenshots');
    }

    for (var id = 1; id <= 50; id++) {
      await open(id);
      expect(tester.takeException(), isNull, reason: 'Screen $id');
      await capture(id.toString().padLeft(2, '0'));
      if ([5, 20, 21, 24, 25, 26, 27, 34, 35, 37].contains(id)) {
        final scroll = find.byType(SingleChildScrollView).first;
        await tester.drag(scroll, const Offset(0, -560));
        await tester.pumpAndSettle();
        await capture('${id}_content');
      }
    }

    await open(22);
    await tester.tap(find.byKey(const ValueKey('favorite')));
    await tester.pumpAndSettle();
    expect(store.favorites, contains('271'));

    await open(28);
    await tester.enterText(find.byKey(const ValueKey('trade-amount')), '1.1');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-trade')));
    await tester.pumpAndSettle();
    expect(store.highestBid, 1.1);
    expect(find.text('Congratulations'), findsOneWidget);

    await open(31);
    await tester.tap(find.byKey(const ValueKey('confirm-trade')));
    await tester.pumpAndSettle();
    expect(store.owned, contains('271'));
    expect(store.balance, closeTo(2785.13, .00001));

    await open(36);
    await tester.enterText(find.byType(TextFormField).first, 'Pixso Collector');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-profile')));
    await tester.pumpAndSettle();
    expect(store.username, 'Pixso Collector');

    await open(49);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(store.notifications.first, isFalse);

    await open(37);
    await tester.tap(find.text('Use sample artwork'));
    await tester.enterText(find.byType(TextFormField).at(0), 'Leafier #272');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Created during the Android integration test.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('create-nft')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-nft')));
    await tester.pumpAndSettle();
    expect(store.created.single.name, 'Leafier #272');
    expect(find.text('Congratulations'), findsOneWidget);
    await tester.tap(find.text('List Item').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-listing')));
    await tester.pumpAndSettle();
    expect(store.transactions.first['type'], 'Fixed price listing');
    await capture('51_created_and_listed');

    await open(14);
    await tester.tap(find.text('Low to High'));
    await tester.tap(find.byKey(const ValueKey('apply-filter')));
    await tester.pumpAndSettle();
    expect(store.filter.sort, 'Low to High');

    await open(12);
    await tester.enterText(find.byType(TextField).first, 'MetaGlow #271');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'MetaGlow #271'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await open(5);
    binding.reportData = {
      'platform': Platform.operatingSystem,
      'screenshotsDirectory': directory.path,
      'designScreens': 50,
      'additionalScreenshots': 11,
      'journeys': [
        'favorite',
        'bid',
        'purchase',
        'profile save',
        'notification switch',
        'create NFT',
        'fixed-price listing',
        'filter',
        'search',
      ],
      'allPassed': true,
    };
  });
}
