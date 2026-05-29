import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';

void main() {
  final storage = StorageService();
  final apiClient = ApiClient(storage);
  final authService = AuthService(apiClient, storage);
  final settingsService = SettingsService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storage)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsService),
        ),
      ],
      child: const SetorunApp(),
    ),
  );
}

class SetorunApp extends StatelessWidget {
  const SetorunApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final mode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp(
      title: 'Setorun App',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: mode,
      home: const AuthGate(),
    );
  }
}
