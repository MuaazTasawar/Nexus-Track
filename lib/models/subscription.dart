class Subscription {
  final String id;
  final String name;
  final double amount;
  final DateTime createdAt;
  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.createdAt,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      createdAt: map['createdAt']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }
}