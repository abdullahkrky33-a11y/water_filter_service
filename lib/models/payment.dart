class Payment {
  final int? id;
  final int customerId;
  final int? serviceId;
  final double amount;
  final String paymentMethod;
  final String paymentDate;
  final String? notes;
  final String createdAt;

  Payment({
    this.id,
    required this.customerId,
    this.serviceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      customerId: map['customer_id'],
      serviceId: map['service_id'],
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      paymentMethod: map['payment_method'] ?? 'Nakit',
      paymentDate: map['payment_date'] ?? '',
      notes: map['notes'],
      createdAt: map['created_at'] ?? '',
    );
  }
}
