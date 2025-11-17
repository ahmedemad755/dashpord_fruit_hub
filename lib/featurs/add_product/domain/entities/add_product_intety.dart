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
  final bool isOrganic;
  final num numberOfcalories;
  final num averageRating;
  final int ratingcount;
  final List<ReviewEntite> reviews;

  AddProductIntety({
    required this.name,
    required this.price,
    required this.code,
    required this.description,
    required this.image,
    this.imageurl,
    required this.expirationDate,
    required this.unitAmount,
    this.isOrganic = false,
    required this.numberOfcalories,
    this.averageRating = 0,
    this.ratingcount = 0,
    required this.reviews,
  });
}
