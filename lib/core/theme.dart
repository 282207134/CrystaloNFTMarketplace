import 'package:flutter/material.dart';

abstract final class C {
  static const background = Color(0xFF181817),
      card = Color(0xFF28211C),
      raised = Color(0xFF362D27);
  static const gold = Color(0xFFF8BB5A),
      muted = Color(0xFFC9C4BB),
      dim = Color(0xFF73706B);
  static const green = Color(0xFF22C55E), red = Color(0xFFEF4444);
}

ThemeData appTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: C.background,
  fontFamily: 'SpaceGrotesk',
  colorScheme: const ColorScheme.dark(
    primary: C.gold,
    onPrimary: C.background,
    surface: C.card,
    onSurface: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
    bodySmall: TextStyle(fontSize: 12, color: C.muted),
  ),
  dividerColor: C.raised,
  splashFactory: InkRipple.splashFactory,
  appBarTheme: const AppBarTheme(
    backgroundColor: C.background,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: C.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: C.muted, fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: C.gold),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: C.red),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? C.gold : C.dim,
    ),
    trackColor: WidgetStateProperty.all(C.raised),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: C.gold,
    contentTextStyle: TextStyle(
      color: C.background,
      fontFamily: 'SpaceGrotesk',
    ),
  ),
);

TextStyle type(
  double size, {
  Color color = Colors.white,
  FontWeight weight = FontWeight.w500,
  double height = 1.3,
}) => TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
);
