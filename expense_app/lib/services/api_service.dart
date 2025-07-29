import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ApiService {
  // ⚠️ REPLACE THIS WITH YOUR ACTUAL IP ADDRESS THAT WORKS IN YOUR PHONE'S BROWSER
  static const String baseUrl =
      'http://192.168.1.22:8000'; // 👈 PUT YOUR WORKING IP HERE!

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Test connection to server
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing connection to: $baseUrl/health');

      final response = await http
          .get(Uri.parse('$baseUrl/health'), headers: headers)
          .timeout(const Duration(seconds: 5));

      print('✅ Connection test result: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // Get all expenses
  static Future<List<Expense>> getExpenses() async {
    try {
      print('📱 Fetching expenses from: $baseUrl/expenses/');

      final response = await http
          .get(Uri.parse('$baseUrl/expenses/'), headers: headers)
          .timeout(const Duration(seconds: 10));

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Cannot connect to server at $baseUrl. Make sure your server is running and accessible from your phone. Error: ${e.message}',
      );
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      print('❌ Error in getExpenses: $e');
      rethrow;
    }
  }

  // Add new expense
  static Future<Expense> addExpense(Expense expense) async {
    try {
      print('➕ Adding expense to: $baseUrl/expenses/');
      print('📝 Expense data: ${json.encode(expense.toJson())}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/expenses/'),
            headers: headers,
            body: json.encode(expense.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Add expense response status: ${response.statusCode}');
      print('📄 Add expense response body: ${response.body}');

      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to add expense: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception(
        'Network error: Cannot connect to server at $baseUrl. Error: ${e.message}',
      );
    } catch (e) {
      print('❌ Error in addExpense: $e');
      rethrow;
    }
  }

  // Get single expense
  static Future<Expense> getExpense(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/expenses/$id'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Expense not found');
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getExpense: $e');
      rethrow;
    }
  }

  // Delete expense
  static Future<bool> deleteExpense(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/expenses/$id'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Expense not found');
      } else {
        throw Exception(
          'Failed to delete expense: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in deleteExpense: $e');
      rethrow;
    }
  }
}
