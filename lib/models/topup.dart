class TopUp {
  final int? id;
  final int userId;
  final double amount;
  final String service;
  final DateTime createdAt;

  TopUp({
    this.id,
    required this.userId,
    required this.amount,
    required this.service,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'service': service,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TopUp.fromMap(Map<String, dynamic> map) {
    return TopUp(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      amount: map['amount'] as double,
      service: map['service'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
