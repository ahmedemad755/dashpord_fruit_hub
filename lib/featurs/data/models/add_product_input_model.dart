// import 'dart:io';

// import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
// import 'package:fruitesdashboard/featurs/data/models/review_model.dart';

// class AddProductInputModel {
//   final String name;
//   final num price;
//   final String code;
//   final String description;
//   final String? imageurl;
//   final File image;
//   final num averageRating;
//   final int ratingcount;
//   final int expirationDate;
//   final num sellingcount;
//   final int unitAmount;
//   final List<ReviewModel> reviews;

//   // الحقول الجديدة
//   final bool hasDiscount;
//   final num discountPercentage;
//   final String? pharmacyId;
//   final bool isAvailable;

//   AddProductInputModel({
//     required this.name,
//     required this.price,
//     required this.code,
//     required this.description,
//     this.imageurl,
//     required this.image,
//     this.averageRating = 0,
//     this.ratingcount = 0,
//     required this.expirationDate,
//     required this.unitAmount,
//     required this.reviews,
//     this.sellingcount = 0,
//     this.hasDiscount = false,
//     this.discountPercentage = 0,
//     this.pharmacyId,
//     this.isAvailable = true,
//   });

//   factory AddProductInputModel.fromentity(AddProductIntety addProductIntety) {
//     return AddProductInputModel(
//       name: addProductIntety.name,
//       price: addProductIntety.price,
//       code: addProductIntety.code,
//       description: addProductIntety.description,
//       imageurl: addProductIntety.imageurl,
//       image: addProductIntety.image,
//       averageRating: addProductIntety.averageRating,
//       ratingcount: addProductIntety.ratingcount,
//       expirationDate: addProductIntety.expirationDate,
//       unitAmount: addProductIntety.unitAmount,
//       reviews: addProductIntety.reviews
//           .map((e) => ReviewModel.fromentity(e))
//           .toList(),
//       hasDiscount: addProductIntety.hasDiscount,
//       discountPercentage: addProductIntety.discountPercentage,
//       pharmacyId: addProductIntety.pharmacyId,
//       isAvailable: addProductIntety.isAvailable,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'price': price,
//       'sellingcount': sellingcount,
//       'code': code,
//       'description': description,
//       'imageurl': imageurl,
//       'averageRating': averageRating,
//       'ratingcount': ratingcount,
//       'expirationDate': expirationDate,
//       'unitAmount': unitAmount,
//       'reviews': reviews.map((e) => e.toJson()).toList(),
//       'hasDiscount': hasDiscount,
//       'discountPercentage': discountPercentage,
//       'pharmacyId': pharmacyId,
//       'isAvailable': isAvailable,
//     };
//   }
// }
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
  final num averageRating;
  final int ratingcount;
  final int expirationDate;
  final num sellingcount;
  final int unitAmount;
  final List<ReviewModel> reviews;
  final bool hasDiscount;
  final num discountPercentage;
  final String? pharmacyId;
  final bool isAvailable;
  final String category; // تمت الإضافة هنا

  AddProductInputModel({
    required this.name,
    required this.price,
    required this.code,
    required this.description,
    this.imageurl,
    required this.image,
    this.averageRating = 0,
    this.ratingcount = 0,
    required this.expirationDate,
    required this.unitAmount,
    required this.reviews,
    this.sellingcount = 0,
    this.hasDiscount = false,
    this.discountPercentage = 0,
    this.pharmacyId,
    this.isAvailable = true,
    required this.category, // تمت الإضافة هنا
  });

  factory AddProductInputModel.fromentity(AddProductIntety addProductIntety) {
    return AddProductInputModel(
      name: addProductIntety.name,
      price: addProductIntety.price,
      code: addProductIntety.code,
      description: addProductIntety.description,
      imageurl: addProductIntety.imageurl,
      image: addProductIntety.image,
      averageRating: addProductIntety.averageRating,
      ratingcount: addProductIntety.ratingcount,
      expirationDate: addProductIntety.expirationDate,
      unitAmount: addProductIntety.unitAmount,
      reviews: addProductIntety.reviews
          .map((e) => ReviewModel.fromentity(e))
          .toList(),
      hasDiscount: addProductIntety.hasDiscount,
      discountPercentage: addProductIntety.discountPercentage,
      pharmacyId: addProductIntety.pharmacyId,
      isAvailable: addProductIntety.isAvailable,
      category: addProductIntety.category, // تمت الإضافة هنا
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
      'averageRating': averageRating,
      'ratingcount': ratingcount,
      'expirationDate': expirationDate,
      'unitAmount': unitAmount,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'hasDiscount': hasDiscount,
      'discountPercentage': discountPercentage,
      'pharmacyId': pharmacyId,
      'isAvailable': isAvailable,
      'category': category, // تمت الإضافة هنا
    };
  }
}