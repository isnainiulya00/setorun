import 'package:flutter/material.dart';


class DashboardScreen extends StatelessWidget { // Nama kelas ini yang dicari
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Selamat datang di Setorun!')),
    );
  }
}