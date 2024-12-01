import 'package:new_expense_tracker/models/database_provider.dart';
import '../models/database_helper.dart';
import '../models/message_model.dart';
import 'dart:math';

class MessageService {
  final DatabaseProvider _dbHelper = DatabaseProvider();

  // Mapping for predefined questions
  final Map<String, String> questionMapping = {
    "what is my expense?": "total_expense",
    "what are my expenses?": "total_expense",
    "show me my total expenses": "total_expense",
    "tell me my total expense": "total_expense",
  };

  // Regex patterns for dynamic queries
  final RegExp categoryExpenseRegex = RegExp(r"what.*expense for (.+)\?");
  final RegExp daysExpenseRegex =
      RegExp(r"what.*expense for the last (\d+) days\?");
  final RegExp highestExpenseRegex = RegExp(r"what.*highest expense\?");
  final RegExp averageExpenseRegex = RegExp(r"what.*average expense\?");
  final RegExp listExpensesRegex = RegExp(r"list.*my expenses\.?");

  // Store a message in the database
  static Future<void> storeMessage(Message message) async {
    final db = await DatabaseHelper().database;
    await db.insert(DatabaseHelper.table, message.toMap());
  }

  // Clear all messages from the database
  static Future<void> clearMessages() async {
    final db = await DatabaseHelper().database;
    await db.delete(DatabaseHelper.table); // Delete all rows from the table
  }

  // Get all messages from the database
  static Future<List<Message>> getMessages() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(DatabaseHelper.table);
    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  // Handle user queries and provide appropriate responses
  Future<String> handleQuery(String userMessage) async {
    String query = userMessage.toLowerCase().trim();

    // Check for predefined questions
    if (questionMapping.containsKey(query)) {
      switch (questionMapping[query]) {
        case "total_expense":
          double totalExpense = await _dbHelper.getTotalExpense();
          return "Your total expense is ₹${totalExpense.toStringAsFixed(2)}.";
      }
    }
    // Check for "What is my expense for [Category]?"
    if (categoryExpenseRegex.hasMatch(query)) {
      String category =
          categoryExpenseRegex.firstMatch(query)?.group(1)?.trim() ?? "";
      double categoryExpense = await _dbHelper.getExpenseByCategory(category);
      return categoryExpense > 0
          ? "Your total expense for $category is ₹${categoryExpense.toStringAsFixed(2)}."
          : "No expenses recorded for $category.";
    }
    // Check for "What is my expense for the last X days?"
    if (daysExpenseRegex.hasMatch(query)) {
      int days =
          int.tryParse(daysExpenseRegex.firstMatch(query)?.group(1) ?? "0") ??
              0;
      double totalExpense = await _dbHelper.getExpenseForLastNDays(days);
      return totalExpense > 0
          ? "Your total expense for the last $days days is ₹${totalExpense.toStringAsFixed(2)}."
          : "No expenses recorded in the last $days days.";
    }
    // Check for "What is the highest expense?"
    if (highestExpenseRegex.hasMatch(query)) {
  final highestExpense = await _dbHelper.getHighestExpense();
  final maxAmount = double.tryParse(highestExpense['maxAmount']?.toString() ?? '0') ?? 0.0;
  final category = highestExpense['category']?.toString() ?? "Unknown";
  return maxAmount > 0
      ? "Your highest expense is ₹${maxAmount.toStringAsFixed(2)} in the category $category."
      : "No expenses recorded yet.";
}
    // Check for "What is my average expense?"
    if (averageExpenseRegex.hasMatch(query)) {
      double averageExpense = await _dbHelper.getAverageExpense();
      return averageExpense > 0
          ? "Your average expense is ₹${averageExpense.toStringAsFixed(2)}."
          : "No expenses recorded yet.";
    }
    // Check for "List all my expenses."
    if (listExpensesRegex.hasMatch(query)) {
      final expenses = await _dbHelper.getAllExpenses();
      return expenses.isNotEmpty
          ? expenses
              .map((e) => "₹${e['amount']} - ${e['category']} on ${e['date']}")
              .join("\n")
          : "No expenses recorded yet.";
    }
    // Fallback for unrecognized input
    return _generateAutoReply(userMessage);
  }

  // Generate auto-replies for unrecognized queries
  String _generateAutoReply(String userMessage) {
    String lowerCaseMessage = userMessage.toLowerCase();
    if (lowerCaseMessage.contains("hello") || lowerCaseMessage.contains("hi")) {
      return _timeBasedGreeting();
    } else if (lowerCaseMessage.contains("thanks") ||
        lowerCaseMessage.contains("thank you")) {
      return "You're welcome! Let me know if you need anything else.";
    }
    return _randomDefaultReply();
  }

  // Generate a time-based greeting
  String _timeBasedGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning! How can I assist you today?";
    } else if (hour < 18) {
      return "Good afternoon! How can I help you today?";
    } else {
      return "Good evening! Let me know if you need assistance.";
    }
  }

  // Generate a random default reply
  String _randomDefaultReply() {
    List<String> replies = [
      "I'm here to assist you! Please provide more details.",
      "Can you clarify what you mean?",
      "Feel free to ask anything related to your expenses or the app.",
      "I'm not sure I understand. Could you please rephrase?",
    ];
    return replies[Random().nextInt(replies.length)];
  }
}
