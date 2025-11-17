import 'dart:io';

import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/data/models/review_model.dart';

class AddProductInputModel {
  final String name;
  final num price;
  final String code;
  final String description;
  final String? imageurl;
  final File image;
  final bool isOrganic;
  final num numberOfcalories;
  final num averageRating;
  final int ratingcount;
  final int expirationDate;
  final num sellingcount;
  final int unitAmount;
  final List<ReviewModel> reviews;
  AddProductInputModel({
    required this.name,
    required this.price,
    required this.code,
    required this.description,
    this.imageurl,
    required this.image,
    this.isOrganic = false,
    this.numberOfcalories = 0,
    this.averageRating = 0,
    this.ratingcount = 0,
    required this.expirationDate,
    required this.unitAmount,
    required this.reviews,
    this.sellingcount = 0,
  });

  factory AddProductInputModel.fromentity(AddProductIntety addProductIntety) {
    return AddProductInputModel(
      name: addProductIntety.name,
      price: addProductIntety.price,
      code: addProductIntety.code,
      description: addProductIntety.description,
      imageurl: addProductIntety.imageurl,
      image: addProductIntety.image,
      isOrganic: addProductIntety.isOrganic,
      numberOfcalories: addProductIntety.numberOfcalories,
      averageRating: addProductIntety.averageRating,
      ratingcount: addProductIntety.ratingcount,
      expirationDate: addProductIntety.expirationDate,
      unitAmount: addProductIntety.unitAmount,
      reviews: addProductIntety.reviews
          .map((e) => ReviewModel.fromentity(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'sellingcount': sellingcount,
      'code': code,
      'description': description,
      'imageurl': imageurl,
      'isOrganic': isOrganic,
      'numberOfcalories': numberOfcalories,
      'averageRating': averageRating,
      'ratingcount': ratingcount,
      'expirationDate': expirationDate,
      'unitAmount': unitAmount,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}
