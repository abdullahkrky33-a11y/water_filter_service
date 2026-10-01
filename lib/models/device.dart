class Device {
  final int? id;
  final int customerId;
  final String brandModel;
  final int filterChangePeriodMonths;
  final String? installationDate;

  Device({
    this.id,
    required this.customerId,
    required this.brandModel,
    required this.filterChangePeriodMonths,
    this.installationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'brand_model': brandModel,
      'filter_change_period_months': filterChangePeriodMonths,
      'installation_date': installationDate,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      customerId: map['customer_id'],
      brandModel: map['brand_model'] ?? '',
      filterChangePeriodMonths: map['filter_change_period_months'] ?? 6,
      installationDate: map['installation_date'],
    );
  }
}
