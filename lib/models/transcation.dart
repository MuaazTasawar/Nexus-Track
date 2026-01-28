class Transaction {
  final String id;
  final String description;
  final double amount;
  final String type; // 'Expense' or 'Income'
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  // Add this if you need JSON conversion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}


