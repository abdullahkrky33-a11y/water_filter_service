class Payment {
  final int? id;
  final int customerId;
  final int? serviceId;
  final double amount;
  final String paymentMethod;
  final String paymentDate;
  final String? notes;
  final String createdAt;

  const Payment({
    this.id,
    required this.customerId,
    this.serviceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'service_id': serviceId,
      'amount': amount,
      'payment_method': paymentMethod.trim(),
      'payment_date': paymentDate,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'created_at': createdAt,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int? ?? 0,
      serviceId: map['service_id'] as int?,
      amount: map['amount'] is num
          ? (map['amount'] as num).toDouble()
          : 0,
      paymentMethod: map['payment_method'] as String? ?? 'Nakit',
      paymentDate: map['payment_date'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  Payment copyWith({
    int? id,
    int? customerId,
    int? serviceId,
    double? amount,
    String? paymentMethod,
    String? paymentDate,
    String? notes,
    String? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
