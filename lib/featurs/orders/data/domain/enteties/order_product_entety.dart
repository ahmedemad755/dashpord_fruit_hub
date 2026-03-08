class OrderProductEntity {
  final String name;
  final String code;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? prescriptionImageUrl;
  final bool isPrescriptionRequired;

  const OrderProductEntity({
    required this.name,
    required this.code,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.prescriptionImageUrl,
    this.isPrescriptionRequired = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'prescriptionImageUrl': prescriptionImageUrl,
      'isPrescriptionRequired': isPrescriptionRequired,
    };
  }

  factory OrderProductEntity.fromJson(Map<String, dynamic> json) {
    return OrderProductEntity(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      prescriptionImageUrl: json['prescriptionImageUrl']?.toString(),
      isPrescriptionRequired: json['isPrescriptionRequired'] as bool? ?? false,
    );
  }

  OrderProductEntity toEntity() => OrderProductEntity(
    name: name,
    code: code,
    imageUrl: imageUrl,
    price: price,
    quantity: quantity,
    prescriptionImageUrl: prescriptionImageUrl,
    isPrescriptionRequired: isPrescriptionRequired,
  );
}
