import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

void main() {
  final storage = StorageService();
  final apiClient = ApiClient(storage);
  final authService = AuthService(apiClient, storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storage)..initialize(),
        ),
      ],
      child: const SetorunApp(),
    ),
  );
}

class SetorunApp extends StatelessWidget {
  const SetorunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Setorun App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
