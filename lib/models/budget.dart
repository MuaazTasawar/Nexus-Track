class Budget {
  final String id;
  final String category;
  final double limit;
  final double used;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.used,
  });

  double get remaining => limit - used;

  double get percentageUsed => limit > 0 ? (used / limit) * 100 : 0;

  bool get isOverBudget => used > limit;

  @override
  String toString() {
    return 'Budget(id: $id, category: $category, limit: $limit, used: $used, remaining: $remaining)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.category == category &&
        other.limit == limit &&
        other.used == used;
  }

  @override
  int get hashCode {
    return id.hashCode ^ category.hashCode ^ limit.hashCode ^ used.hashCode;
  }
}
