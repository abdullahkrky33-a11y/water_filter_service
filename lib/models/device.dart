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
  final int filterChangePeriodMonths;
  final String createdAt;
  final String? updatedAt;

  Device({
    this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    this.serialNumber,
    this.installationDate,
    this.deviceType,
    this.tankCapacity,
    this.pumpType,
    this.filterChangePeriodMonths = 6,
    required this.createdAt,
    this.updatedAt,
  });

  String get brandModel => '$brand $model'.trim();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'installation_date': installationDate,
      'device_type': deviceType,
      'tank_capacity': tankCapacity,
      'pump_type': pumpType,
      'filter_change_period_months': filterChangePeriodMonths,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      customerId: map['customer_id'],
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      serialNumber: map['serial_number'],
      installationDate: map['installation_date'],
      deviceType: map['device_type'],
      tankCapacity: map['tank_capacity'],
      pumpType: map['pump_type'],
      filterChangePeriodMonths: map['filter_change_period_months'] ?? 6,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'],
    );
  }
}
