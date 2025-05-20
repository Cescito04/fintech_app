class Transaction {
  final int? id;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime date;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      amount: map['amount'] as double,
      type: map['type'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    int? userId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
