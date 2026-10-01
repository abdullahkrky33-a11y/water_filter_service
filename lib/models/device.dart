class Device {
  final int? id;
  final int customerId;
  final String brand;
  final String model;
  final String? serialNumber;
  final DateTime installationDate;
  final String deviceType;
  final String? tankCapacity;
  final String? pumpType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Device({
    this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    this.serialNumber,
    required this.installationDate,
    required this.deviceType,
    this.tankCapacity,
    this.pumpType,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'installation_date': installationDate.toIso8601String(),
      'device_type': deviceType,
      'tank_capacity': tankCapacity,
      'pump_type': pumpType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      serialNumber: map['serial_number'] as String?,
      installationDate: map['installation_date'] != null ? DateTime.parse(map['installation_date'] as String) : DateTime.now(),
      deviceType: map['device_type'] as String? ?? '',
      tankCapacity: map['tank_capacity'] as String?,
      pumpType: map['pump_type'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now(),
    );
  }
}
