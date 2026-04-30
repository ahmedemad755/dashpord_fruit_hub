import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/featurs/offers/domain/entities/fer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.discountPercentage,
    required super.expiryDate,
    required super.pharmacyId,
    super.isActive,
  });

  // من جيسون (للقراءة من فيربيز)
  factory OfferModel.fromJson(Map<String, dynamic> json, String documentId) {
    return OfferModel(
      id: documentId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: json['discountPercentage'] ?? 0,
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      pharmacyId: json['pharmacyId'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  // تحويل الـ Entity إلى Model
  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      discountPercentage: entity.discountPercentage,
      expiryDate: entity.expiryDate,
      pharmacyId: entity.pharmacyId,
      isActive: entity.isActive,
    );
  }

  // إلى جيسون (للكتابة في فيربيز)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'pharmacyId': pharmacyId,
      'isActive': isActive,
    };
  }
}