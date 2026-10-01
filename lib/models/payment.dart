class Payment {
  final int? id;
  final int customerId;
  final int serviceId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.customerId,
    required this.serviceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      serviceId: map['service_id'] as int,
      amount: (map['amount'] as num? ?? 0.0).toDouble(),
      paymentMethod: map['payment_method'] as String? ?? 'Nakit',
      paymentDate: map['payment_date'] != null ? DateTime.parse(map['payment_date'] as String) : DateTime.now(),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }
}
