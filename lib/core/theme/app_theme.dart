import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal));
  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
    scaffoldBackgroundColor: const Color(0xFFF8FAFB),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}