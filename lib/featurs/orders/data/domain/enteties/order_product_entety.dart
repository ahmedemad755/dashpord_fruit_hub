class OrderProductEntity {
  final String name;
  final String code;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? pharmacyName; // 👈 إضافة الحقل هنا
  final String? prescriptionImageUrl;
  final bool isPrescriptionRequired;
  final String? cancelledBy; // 👈 إضافة الحقل هنا

  const OrderProductEntity({
    required this.name,
    required this.code,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.prescriptionImageUrl,
    this.pharmacyName,
    this.isPrescriptionRequired = false,
    this.cancelledBy, // 👈 إضافته للـ Constructor
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
      if (pharmacyName != null) 'pharmacyName': pharmacyName,
      if (cancelledBy != null) 'cancelledBy': cancelledBy, // 👈 تضمينه في الـ JSON
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
      pharmacyName: json['pharmacyName'], // 👈 قراءة الحقل من الـ JSON
      cancelledBy: json['cancelledBy']?.toString(), // 👈 قراءة الحقل من الـ JSON

    );
  }

  OrderProductEntity toEntity() => OrderProductEntity(
    name: name,
    code: code,
    imageUrl: imageUrl,
    price: price,
    quantity: quantity,
      pharmacyName: pharmacyName, // 👈 تضمينه في التحويل إلى Entity
    prescriptionImageUrl: prescriptionImageUrl,
    isPrescriptionRequired: isPrescriptionRequired,
    cancelledBy: cancelledBy, // 👈 تضمينه في التحويل إلى Entity
  );
}
