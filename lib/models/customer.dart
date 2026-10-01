class Customer {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? secondaryPhone;
  final String address;
  final String district;
  final String city;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.secondaryPhone,
    required this.address,
    required this.district,
    required this.city,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'secondary_phone': secondaryPhone,
      'address': address,
      'district': district,
      'city': city,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      secondaryPhone: map['secondary_phone'] as String?,
      address: map['address'] as String? ?? '',
      district: map['district'] as String? ?? '',
      city: map['city'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now(),
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }
}
