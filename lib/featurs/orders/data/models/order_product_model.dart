import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_product_entety.dart';

class OrderProductModel extends OrderProductEntity {
  const OrderProductModel({
    required super.name,
    required super.code,
    required super.imageUrl,
    required super.price,
    required super.quantity,
    super.isPrescriptionRequired = false,
    super.prescriptionImageUrl,
    super.cancelledBy,
    super.pharmacyName,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      isPrescriptionRequired: json['isPrescriptionRequired'] as bool? ?? false,
      prescriptionImageUrl: json['prescriptionImageUrl']?.toString(),
      cancelledBy: json['cancelledBy']?.toString(),
      pharmacyName: json['pharmacyName'],
    );
  }

  factory OrderProductModel.fromEntity(OrderProductEntity entity) {
    return OrderProductModel(
      name: entity.name,
      code: entity.code,
      imageUrl: entity.imageUrl,
      price: entity.price,
      quantity: entity.quantity,
      isPrescriptionRequired: entity.isPrescriptionRequired,
      prescriptionImageUrl: entity.prescriptionImageUrl,
      cancelledBy: entity.cancelledBy,
      pharmacyName: entity.pharmacyName,
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
      'isPrescriptionRequired': isPrescriptionRequired,
      if (prescriptionImageUrl != null) 'prescriptionImageUrl': prescriptionImageUrl,
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (pharmacyName != null) 'pharmacyName': pharmacyName,
    };
  }

  @override
  OrderProductEntity toEntity() => OrderProductEntity(
        name: name,
        code: code,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity,
        isPrescriptionRequired: isPrescriptionRequired,
        prescriptionImageUrl: prescriptionImageUrl,
        cancelledBy: cancelledBy,
        pharmacyName: pharmacyName,
      );
}