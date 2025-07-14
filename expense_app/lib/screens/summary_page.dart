// lib/screens/summary_page.dart
import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: const Center(child: Text('Summary of your expenses')),
    );
  }
}
// This file defines the SummaryPage widget, which serves as a screen for displaying a summary of expenses.
// It includes an AppBar with a title and a centered text message indicating where the summary will be displayed.