class ServiceRecord {
  final int? id;
  final int customerId;
  final String serviceDate;
  final DateTime nextServiceDate;
  final String? notes;

  ServiceRecord({
    this.id,
    required this.customerId,
    required this.serviceDate,
    required this.nextServiceDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_date': serviceDate,
      'next_service_date': nextServiceDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'],
      customerId: map['customer_id'],
      serviceDate: map['service_date'] ?? '',
      nextServiceDate: map['next_service_date'] != null
          ? DateTime.parse(map['next_service_date'])
          : DateTime.now(),
      notes: map['notes'],
    );
  }
}
