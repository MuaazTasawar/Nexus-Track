// models/payment_method.dart
class PaymentMethod {
  final String id;
  final String name;
  final String? cardType;  // Make nullable if not always present
  final String? lastFour;  // Make nullable if not always present

  PaymentMethod({
    required this.id,
    required this.name,
    this.cardType,
    this.lastFour,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cardType': cardType,
      'lastFour': lastFour,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      cardType: map['cardType'],
      lastFour: map['lastFour'],
    );
  }
}