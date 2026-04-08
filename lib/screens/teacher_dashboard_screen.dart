import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Guru")),
      body: const Center(
        child: Text("Fitur Guru (CRUD Mutabaah nanti di sini)"),
      ),
    );
  }
}
