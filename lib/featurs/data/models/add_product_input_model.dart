
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/data/models/review_model.dart';
import 'package:image_picker/image_picker.dart';

class AddProductInputModel {
  final String name;
  final num price;
  final num cost;
  final String code;
  final String description;
  final String? imageurl;
  final XFile? image;
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
  final bool isPrescriptionRequired;

  AddProductInputModel({
    required this.name,
    required this.price,
    required this.cost,
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
      this.isPrescriptionRequired = false, // تمت الإضافة هنا
  });

  factory AddProductInputModel.fromentity(AddProductIntety addProductIntety) {
    return AddProductInputModel(
      name: addProductIntety.name,
      price: addProductIntety.price,
      cost: addProductIntety.cost,
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
      isPrescriptionRequired: addProductIntety.isPrescriptionRequired,
    );
  }
  // 2️⃣ تحويل الـ Map القادم من Firestore إلى Model (حل مشكلة getProducts)
  factory AddProductInputModel.fromJson(Map<String, dynamic> json) {
    return AddProductInputModel(
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      cost: json['cost'] ?? 0,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      imageurl: json['imageurl'],
      image: null, // لا يمكن استرجاع XFile من Firestore
      averageRating: json['averageRating'] ?? 0,
      ratingcount: json['ratingcount'] ?? 0,
      expirationDate: json['expirationDate'] ?? 0,
      unitAmount: json['unitAmount'] ?? 0,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((e) => ReviewModel.fromJson(e))
              .toList()
          : [],
      sellingcount: json['sellingcount'] ?? 0,
      hasDiscount: json['hasDiscount'] ?? false,
      discountPercentage: json['discountPercentage'] ?? 0,
      pharmacyId: json['pharmacyId'],
      isAvailable: json['isAvailable'] ?? true,
      category: json['category'] ?? '',
      isPrescriptionRequired: json['isPrescriptionRequired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'cost': cost,
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
      'isPrescriptionRequired': isPrescriptionRequired,
    };
  }
  AddProductIntety toEntity() {
    return AddProductIntety(
      name: name,
      price: price,
      cost: cost,
      code: code,
      description: description,
      imageurl: imageurl,
      image: image!, // ملاحظة: تأكد أن الـ Entity يقبل Null في حقل الصورة عند العرض
      averageRating: averageRating,
      ratingcount: ratingcount,
      expirationDate: expirationDate,
      unitAmount: unitAmount,
      reviews: reviews.map((e) => e.toEntity()).toList(),
      hasDiscount: hasDiscount,
      discountPercentage: discountPercentage,
      pharmacyId: pharmacyId,
      isAvailable: isAvailable,
      category: category,
      isPrescriptionRequired: isPrescriptionRequired,
    );
  }
}
