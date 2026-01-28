import 'package:flutter/material.dart';

class SharedExpense {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime date;

  SharedExpense({
    required this.id,
    required this.name,
    required this.amount,
    this.category = 'Other',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  // Create from Map when loading
  factory SharedExpense.fromMap(Map<String, dynamic> map) {
    return SharedExpense(
      id: map['id'],
      name: map['name'],
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
      date: DateTime.parse(map['date']),
    );
  }

  // Helper method to format date
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get icon based on category
  IconData get categoryIcon {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Travel':
        return Icons.flight;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }
}