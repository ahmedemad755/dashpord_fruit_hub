import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/shipping_address_entety.dart';

class ShippingAddressModel extends ShippingAddressEntity {
  const ShippingAddressModel({
    super.name,
    super.phone,
    super.address,
    super.floor,
    super.city,
    super.email,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      floor: json['floor']?.toString(),
      city: json['city']?.toString(),
      email: json['email']?.toString(),
    );
  }

  factory ShippingAddressModel.fromEntity(ShippingAddressEntity entity) {
    return ShippingAddressModel(
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      floor: entity.floor,
      city: entity.city,
      email: entity.email,
    );
  }

  @override
  String toString() {
    return '${address ?? ''} ${floor ?? ''} ${city ?? ''}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'floor': floor,
      'city': city,
      'email': email,
    };
  }

  ShippingAddressEntity toEntity() => ShippingAddressEntity(
    name: name,
    phone: phone,
    address: address,
    floor: floor,
    city: city,
    email: email,
  );
}
