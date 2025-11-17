class ShippingAddressEntity {
  final String? name;
  final String? phone;
  final String? address;
  final String? city;
  final String? email;
  final String? floor;

  const ShippingAddressEntity({
    this.name,
    this.phone,
    this.address,
    this.floor,
    this.city,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'email': email,
      'floor': floor,
    };
  }

  factory ShippingAddressEntity.fromJson(Map<String, dynamic> json) {
    return ShippingAddressEntity(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      email: json['email']?.toString(),
      floor: json['floor']?.toString(),
    );
  }

  @override
  String toString() {
    return '$address, $floor, $city';
  }
}
