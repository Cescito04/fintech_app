class Account {
  final int? id;
  final int userId;
  final String accountNumber;
  final double balance;
  final String type;
  final DateTime createdAt;

  Account({
    this.id,
    required this.userId,
    required this.accountNumber,
    required this.balance,
    required this.type,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      accountNumber: map['accountNumber'] as String,
      balance: map['balance'] as double,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'accountNumber': accountNumber,
      'balance': balance,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Account copyWith({
    int? id,
    int? userId,
    String? accountNumber,
    double? balance,
    String? type,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
