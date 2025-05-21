class Transfer {
  final int? id;
  final String fromPhone;
  final String toPhone;
  final double amount;
  final DateTime createdAt;

  Transfer({
    this.id,
    required this.fromPhone,
    required this.toPhone,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromPhone': fromPhone,
      'toPhone': toPhone,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      id: map['id'] as int?,
      fromPhone: map['fromPhone'] as String,
      toPhone: map['toPhone'] as String,
      amount: map['amount'] as double,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
