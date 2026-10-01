class ServiceFilter {
  final int? id;
  final int serviceId;
  final int filterId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  const ServiceFilter({
    this.id,
    required this.serviceId,
    required this.filterId,
    this.quantity = 1,
    this.unitPrice = 0,
    this.totalPrice = 0,
    this.notes,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final calculatedTotal = totalPrice > 0
        ? totalPrice
        : quantity * unitPrice;

    final map = <String, dynamic>{
      'service_id': serviceId,
      'filter_id': filterId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': calculatedTotal,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory ServiceFilter.fromMap(Map<String, dynamic> map) {
    return ServiceFilter(
      id: map['id'] as int?,
      serviceId: map['service_id'] as int? ?? 0,
      filterId: map['filter_id'] as int? ?? 0,
      quantity: map['quantity'] as int? ?? 1,
      unitPrice: map['unit_price'] is num
          ? (map['unit_price'] as num).toDouble()
          : 0,
      totalPrice: map['total_price'] is num
          ? (map['total_price'] as num).toDouble()
          : 0,
      notes: map['notes'] as String?,
    );
  }

  ServiceFilter copyWith({
    int? id,
    int? serviceId,
    int? filterId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? notes,
  }) {
    return ServiceFilter(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      filterId: filterId ?? this.filterId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
    );
  }
}
