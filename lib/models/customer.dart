class Customer {
  final int? id;
  final String fullName;
  final String phone;
  final String address;
  final String? notes;
  final String createdAt;

  Customer({
    this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'],
      createdAt: map['created_at'] ?? '',
    );
  }
}
