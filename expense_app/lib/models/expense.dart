class Expense {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.createdAt,
  });

  // Convert from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Convert to JSON (for API calls)
  Map<String, dynamic> toJson() {
    return {'title': title, 'amount': amount, 'category': category};
  }

  // Convert to JSON with ID (for complete data)
  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, createdAt: $createdAt)';
  }
}
