import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:saathi/firebase_options.dart';
import 'package:saathi/screens/auth.dart';
import 'package:saathi/screens/splash.dart';
import 'package:saathi/screens/travel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SaathiApp());
}

class SaathiApp extends StatelessWidget {
  const SaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData) {
            return const TravelScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

var colorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 229, 59, 178),
  surface: const Color.fromARGB(255, 247, 190, 223),
);
var darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 126, 36, 222),
  surface: const Color.fromARGB(255, 6, 4, 42),
);

final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.latoTextTheme(ThemeData().textTheme).apply(
    bodyColor: darkColorScheme.secondaryContainer,
  ),
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: colorScheme.onPrimaryContainer,
    foregroundColor: colorScheme.primaryContainer,
  ),
);

final darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: darkColorScheme.surface,
  colorScheme: darkColorScheme,
  textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: darkColorScheme.onSurface,
  ),
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: darkColorScheme.onPrimaryContainer,
    foregroundColor: darkColorScheme.primaryContainer,
  ),
);
