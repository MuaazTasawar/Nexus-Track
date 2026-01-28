import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/auth/login_page.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00FFD1),
          secondary: Colors.cyanAccent,
          surface: Colors.transparent,
          onSurface: Colors.white,
        ),
        splashColor: const Color(0xFF00FFD1).withOpacity(0.2),
        highlightColor: const Color(0xFF00FFD1).withOpacity(0.4),
        textTheme: GoogleFonts.orbitronTextTheme(
          ThemeData.dark(useMaterial3: true).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ).copyWith(
          headlineMedium: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent,
          ),
          bodyLarge: GoogleFonts.exo2(fontSize: 16, color: Colors.white),
          bodyMedium: GoogleFonts.exo2(fontSize: 14, color: Colors.white70),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent,
          ),
          iconTheme: const IconThemeData(color: Colors.tealAccent),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
          elevation: 8,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        dialogBackgroundColor: Colors.transparent,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.tealAccent),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.tealAccent,
            textStyle: GoogleFonts.exo2(fontSize: 14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            elevation: 10,
            shadowColor: Colors.tealAccent.withOpacity(0.3),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Colors.cyanAccent.withOpacity(0.2),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.transparent,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 0,
        ),
      ),
      home: LoginPage(),
    );
  }
}
