class Device {
  final int? id;
  final int customerId;
  final String brand;
  final String model;
  final String? serialNumber;
  final String? installationDate;
  final String? deviceType;
  final String? tankCapacity;
  final String? pumpType;
  final String createdAt;
  final String? updatedAt;
  final bool isActive;

  const Device({
    this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    this.serialNumber,
    this.installationDate,
    this.deviceType,
    this.tankCapacity,
    this.pumpType,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  String get brandModel => '$brand $model'.trim();

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'brand': brand.trim(),
      'model': model.trim(),
      'serial_number': serialNumber?.trim().isEmpty == true
          ? null
          : serialNumber?.trim(),
      'installation_date': installationDate,
      'device_type': deviceType?.trim().isEmpty == true
          ? null
          : deviceType?.trim(),
      'tank_capacity': tankCapacity?.trim().isEmpty == true
          ? null
          : tankCapacity?.trim(),
      'pump_type': pumpType?.trim().isEmpty == true
          ? null
          : pumpType?.trim(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': isActive ? 1 : 0,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int? ?? 0,
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      serialNumber: map['serial_number'] as String?,
      installationDate: map['installation_date'] as String?,
      deviceType: map['device_type'] as String?,
      tankCapacity: map['tank_capacity'] as String?,
      pumpType: map['pump_type'] as String?,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String?,
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  Device copyWith({
    int? id,
    int? customerId,
    String? brand,
    String? model,
    String? serialNumber,
    String? installationDate,
    String? deviceType,
    String? tankCapacity,
    String? pumpType,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
  }) {
    return Device(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      installationDate: installationDate ?? this.installationDate,
      deviceType: deviceType ?? this.deviceType,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      pumpType: pumpType ?? this.pumpType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
