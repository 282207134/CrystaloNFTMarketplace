import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Space Grotesk',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF181817),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final preferences = await SharedPreferences.getInstance();
  const screen = int.fromEnvironment('SCREEN', defaultValue: 1);
  runApp(CrystaloApp(store: AppStore(preferences), initialScreen: screen));
}
