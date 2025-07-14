// lib/screens/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text(
          'Welcome to the Expense Tracker!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// This file defines the HomePage widget, which serves as the main screen of the Expense Tracker app.
// It includes an AppBar with a title and a centered text message welcoming users to the app
