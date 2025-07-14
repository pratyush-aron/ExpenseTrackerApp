// lib/screens/add_expense_page.dart
import 'package:flutter/material.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: const Center(child: Text('Form to add a new expense here')),
    );
  }
}
// This file defines the AddExpensePage widget, which serves as a screen for adding new expenses.
// It includes an AppBar with a title and a centered text message indicating where the form to