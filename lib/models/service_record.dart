class ServiceRecord {
  final int? id;
  final int customerId;
  final int deviceId;
  final DateTime serviceDate;
  final String serviceType;
  final String? description;
  final double totalAmount;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;

  ServiceRecord({
    this.id,
    required this.customerId,
    required this.deviceId,
    required this.serviceDate,
    required this.serviceType,
    this.description,
    required this.totalAmount,
    required this.paymentStatus,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'device_id': deviceId,
      'service_date': serviceDate.toIso8601String(),
      'service_type': serviceType,
      'description': description,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      deviceId: map['device_id'] as int,
      serviceDate: map['service_date'] != null ? DateTime.parse(map['service_date'] as String) : DateTime.now(),
      serviceType: map['service_type'] as String? ?? '',
      description: map['description'] as String?,
      totalAmount: (map['total_amount'] as num? ?? 0.0).toDouble(),
      paymentStatus: map['payment_status'] as String? ?? 'PENDING',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }
}
