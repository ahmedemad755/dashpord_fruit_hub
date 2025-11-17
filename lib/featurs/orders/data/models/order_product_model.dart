import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_product_entety.dart';

class OrderProductModel extends OrderProductEntity {
  const OrderProductModel({
    required super.name,
    required super.code,
    required super.imageUrl,
    required super.price,
    required super.quantity,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  factory OrderProductModel.fromEntity(OrderProductEntity entity) {
    return OrderProductModel(
      name: entity.name,
      code: entity.code,
      imageUrl: entity.imageUrl,
      price: entity.price,
      quantity: entity.quantity,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  @override
  OrderProductEntity toEntity() => OrderProductEntity(
    name: name,
    code: code,
    imageUrl: imageUrl,
    price: price,
    quantity: quantity,
  );
}
