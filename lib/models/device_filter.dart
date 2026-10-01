class DeviceFilter {
  final int? id;
  final int deviceId;
  final int filterId;
  final String? installedAt;
  final String? lastChangedAt;
  final String? nextChangeDate;
  final double currentPrice;
  final bool isActive;
  final String? notes;

  const DeviceFilter({
    this.id,
    required this.deviceId,
    required this.filterId,
    this.installedAt,
    this.lastChangedAt,
    this.nextChangeDate,
    this.currentPrice = 0,
    this.isActive = true,
    this.notes,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'device_id': deviceId,
      'filter_id': filterId,
      'installed_at': installedAt,
      'last_changed_at': lastChangedAt,
      'next_change_date': nextChangeDate,
      'current_price': currentPrice,
      'is_active': isActive ? 1 : 0,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory DeviceFilter.fromMap(Map<String, dynamic> map) {
    return DeviceFilter(
      id: map['id'] as int?,
      deviceId: map['device_id'] as int? ?? 0,
      filterId: map['filter_id'] as int? ?? 0,
      installedAt: map['installed_at'] as String?,
      lastChangedAt: map['last_changed_at'] as String?,
      nextChangeDate: map['next_change_date'] as String?,
      currentPrice: map['current_price'] is num
          ? (map['current_price'] as num).toDouble()
          : 0,
      isActive: (map['is_active'] ?? 1) == 1,
      notes: map['notes'] as String?,
    );
  }

  DeviceFilter copyWith({
    int? id,
    int? deviceId,
    int? filterId,
    String? installedAt,
    String? lastChangedAt,
    String? nextChangeDate,
    double? currentPrice,
    bool? isActive,
    String? notes,
  }) {
    return DeviceFilter(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      filterId: filterId ?? this.filterId,
      installedAt: installedAt ?? this.installedAt,
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
      nextChangeDate: nextChangeDate ?? this.nextChangeDate,
      currentPrice: currentPrice ?? this.currentPrice,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}
