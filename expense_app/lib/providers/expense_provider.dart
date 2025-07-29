import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculate total balance
  double get totalBalance {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Load all expenses
  Future<void> loadExpenses() async {
    _setLoading(true);
    _setError(null);

    try {
      _expenses = await ApiService.getExpenses();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      if (kDebugMode) {
        print('Error loading expenses: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Add new expense
  Future<bool> addExpense(Expense expense) async {
    _setLoading(true);
    _setError(null);

    try {
      final newExpense = await ApiService.addExpense(expense);
      _expenses.add(newExpense);
      _setError(null);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      if (kDebugMode) {
        print('Error adding expense: $e');
      }
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await ApiService.deleteExpense(id);
      if (success) {
        _expenses.removeWhere((expense) => expense.id == id);
        _setError(null);
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      if (kDebugMode) {
        print('Error deleting expense: $e');
      }
      return false;
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Refresh expenses
  Future<void> refreshExpenses() async {
    await loadExpenses();
  }
}
