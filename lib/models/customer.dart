class Customer {
  final int? id;
  final String fullName;
  final String phone;
  final String? secondaryPhone;
  final String address;
  final String? city;
  final String? district;
  final String? notes;
  final String createdAt;
  final String? updatedAt;
  final bool isActive;

  const Customer({
    this.id,
    required this.fullName,
    required this.phone,
    this.secondaryPhone,
    required this.address,
    this.city,
    this.district,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'secondary_phone': secondaryPhone?.trim().isEmpty == true
          ? null
          : secondaryPhone?.trim(),
      'address': address.trim(),
      'city': city?.trim().isEmpty == true ? null : city?.trim(),
      'district': district?.trim().isEmpty == true
          ? null
          : district?.trim(),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': isActive ? 1 : 0,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      secondaryPhone: map['secondary_phone'] as String?,
      address: map['address'] as String? ?? '',
      city: map['city'] as String?,
      district: map['district'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String?,
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  Customer copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? secondaryPhone,
    String? address,
    String? city,
    String? district,
    String? notes,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
