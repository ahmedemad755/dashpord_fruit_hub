import 'dart:io';

import 'package:fruitesdashboard/featurs/add_product/domain/entities/review_entite.dart';
import 'package:image_picker/image_picker.dart';

class AddProductIntety {
  late final String name;
  final num price;
  final num cost;
  final String code;
  final String description;
  final XFile image;
  String? imageurl;
  final int expirationDate;
  final int unitAmount;
  final num averageRating;
  final int ratingcount;
  final List<ReviewEntite> reviews;
final bool isPrescriptionRequired;
  // الحقول الجديدة المضافة للتحسين
  final bool hasDiscount;
  final num discountPercentage;
  final String? pharmacyId;
  final bool isAvailable;
  final String category; // الحقل الذي تمت إضافته ليكون ديناميكياً

  AddProductIntety({
    required this.name,
    required this.price,
    required this.cost,
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
    this.isPrescriptionRequired = false,
    required this.category, // تمت إضافته هنا
  });

  DateTime get expirationDateTime => DateTime(
    expirationDate ~/ 10000,
    (expirationDate % 10000) ~/ 100,
    expirationDate % 100,
  );

  String get formattedExpirationDate =>
      "${expirationDateTime.day}-${expirationDateTime.month}-${expirationDateTime.year}";

  num get finalPrice =>
      hasDiscount ? price - (price * (discountPercentage / 100)) : price;
}
