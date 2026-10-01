class Filter {
  final int? id;
  final String name;
  final String type;
  final int replacementPeriodMonths;
  final double defaultPrice;
  final String? description;
  final bool isActive;

  const Filter({
    this.id,
    required this.name,
    required this.type,
    required this.replacementPeriodMonths,
    this.defaultPrice = 0,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'name': name.trim(),
      'type': type.trim(),
      'replacement_period_months': replacementPeriodMonths,
      'default_price': defaultPrice,
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      'is_active': isActive ? 1 : 0,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Filter.fromMap(Map<String, dynamic> map) {
    return Filter(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? '',
      replacementPeriodMonths:
          map['replacement_period_months'] as int? ?? 6,
      defaultPrice: map['default_price'] is num
          ? (map['default_price'] as num).toDouble()
          : 0,
      description: map['description'] as String?,
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  Filter copyWith({
    int? id,
    String? name,
    String? type,
    int? replacementPeriodMonths,
    double? defaultPrice,
    String? description,
    bool? isActive,
  }) {
    return Filter(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      replacementPeriodMonths:
          replacementPeriodMonths ?? this.replacementPeriodMonths,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
