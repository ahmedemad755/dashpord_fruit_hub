import 'dart:io';

import 'package:fruitesdashboard/featurs/add_product/domain/entities/review_entite.dart';

class AddProductIntety {
  late final String name;
  final num price;
  final String code;
  final String description;
  final File image;
  String? imageurl;
  final int expirationDate;
  final int unitAmount;
  final num averageRating;
  final int ratingcount;
  final List<ReviewEntite> reviews;

  // الحقول الجديدة المضافة للتحسين
  final bool hasDiscount;
  final num discountPercentage;
  final String? pharmacyId; // لربط المنتج بالصيدلية
  final bool isAvailable;

  AddProductIntety({
    required this.name,
    required this.price,
    required this.code,
    required this.description,
    required this.image,
    this.imageurl,
    required this.expirationDate,
    required this.unitAmount,
    this.averageRating = 0,
    this.ratingcount = 0,
    required this.reviews,
    this.hasDiscount = false,
    this.discountPercentage = 0,
    this.pharmacyId,
    this.isAvailable = true,
  });

  DateTime get expirationDateTime => DateTime(
    expirationDate ~/ 10000,
    (expirationDate % 10000) ~/ 100,
    expirationDate % 100,
  );

  String get formattedExpirationDate =>
      "${expirationDateTime.day}-${expirationDateTime.month}-${expirationDateTime.year}";

  // حساب السعر النهائي بعد الخصم
  num get finalPrice =>
      hasDiscount ? price - (price * (discountPercentage / 100)) : price;
}
