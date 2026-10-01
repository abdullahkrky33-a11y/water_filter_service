class Filter {
  final int? id;
  final String name;
  final String type;
  final int replacementPeriodMonths;
  final String? description;
  final bool isActive;

  Filter({
    this.id,
    required this.name,
    required this.type,
    required this.replacementPeriodMonths,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'replacement_period_months': replacementPeriodMonths,
      'description': description,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Filter.fromMap(Map<String, dynamic> map) {
    return Filter(
      id: map['id'],
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      replacementPeriodMonths: map['replacement_period_months'] ?? 6,
      description: map['description'],
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }
}
