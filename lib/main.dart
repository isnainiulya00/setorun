import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart'; // Ubah import ini

void main() {
  runApp(const SetorunApp());
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
      home: const LoginScreen(), // Ubah ini agar mengarah ke LoginScreen
    );
  }
}