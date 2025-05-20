class User {
  final int? id;
  final String phone;
  final String pin;
  final String fullName;
  final String? profileImage;
  final String cardNumber;
  final DateTime createdAt;

  User({
    this.id,
    required this.phone,
    required this.pin,
    required this.fullName,
    this.profileImage,
    required this.cardNumber,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      phone: map['phone'] as String,
      pin: map['pin'] as String,
      fullName: map['fullName'] as String,
      profileImage: map['profileImage'] as String?,
      cardNumber: map['cardNumber'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'pin': pin,
      'fullName': fullName,
      'profileImage': profileImage,
      'cardNumber': cardNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? phone,
    String? pin,
    String? fullName,
    String? profileImage,
    String? cardNumber,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      pin: pin ?? this.pin,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      cardNumber: cardNumber ?? this.cardNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
