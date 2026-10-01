class ServiceRecord {
  final int? id;
  final int customerId;
  final int? deviceId;
  final String serviceDate;
  final String? nextServiceDate;
  final String serviceType;
  final String? description;
  final double totalAmount;
  final String paymentStatus;
  final String? notes;
  final String createdAt;

  const ServiceRecord({
    this.id,
    required this.customerId,
    this.deviceId,
    required this.serviceDate,
    this.nextServiceDate,
    this.serviceType = 'Bakım',
    this.description,
    this.totalAmount = 0,
    this.paymentStatus = 'Ödenmedi',
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'device_id': deviceId,
      'service_date': serviceDate,
      'next_service_date': nextServiceDate,
      'service_type': serviceType.trim(),
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      'total_amount': totalAmount,
      'payment_status': paymentStatus.trim(),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'created_at': createdAt,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int? ?? 0,
      deviceId: map['device_id'] as int?,
      serviceDate: map['service_date'] as String? ?? '',
      nextServiceDate: map['next_service_date'] as String?,
      serviceType: map['service_type'] as String? ?? 'Bakım',
      description: map['description'] as String?,
      totalAmount: map['total_amount'] is num
          ? (map['total_amount'] as num).toDouble()
          : 0,
      paymentStatus: map['payment_status'] as String? ?? 'Ödenmedi',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  ServiceRecord copyWith({
    int? id,
    int? customerId,
    int? deviceId,
    String? serviceDate,
    String? nextServiceDate,
    String? serviceType,
    String? description,
    double? totalAmount,
    String? paymentStatus,
    String? notes,
    String? createdAt,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      deviceId: deviceId ?? this.deviceId,
      serviceDate: serviceDate ?? this.serviceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
