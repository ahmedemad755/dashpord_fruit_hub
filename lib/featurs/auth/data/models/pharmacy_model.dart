import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/pharmacy_entity.dart';

class PharmacyModel extends PharmacyEntity {
  PharmacyModel({
    required super.uId,
    required super.pharmacyName,
    required super.email,
    required super.phoneNumber,
    required super.address,
    required super.licenseUrl,
    required super.status,
    required super.role,
    required super.createdAt,
    required super.pharmacistName,
    required super.pharmacistId,
    required super.licenseNumber,
    required super.nationalId,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      uId: json['uId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      licenseUrl: json['licenseUrl'] ?? '',
      status: json['status'] ?? 'pending',
      role: json['role'] ?? 'pharmacy',
      pharmacistName: json['pharmacistName'] ?? '',
      pharmacistId: json['pharmacistId'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      nationalId: json['nationalId'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'pharmacyName': pharmacyName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'licenseUrl': licenseUrl,
      'status': status,
      'role': role,
      'pharmacistName': pharmacistName,
      'pharmacistId': pharmacistId,
      'licenseNumber': licenseNumber,
      'createdAt': createdAt,
      'nationalId': nationalId,
    };
  }

  factory PharmacyModel.fromEntity(PharmacyEntity entity) {
    return PharmacyModel(
      uId: entity.uId,
      pharmacyName: entity.pharmacyName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      licenseUrl: entity.licenseUrl,
      status: entity.status,
      role: entity.role,
      createdAt: entity.createdAt,
      pharmacistName: entity.pharmacistName,
      pharmacistId: entity.pharmacistId,
      licenseNumber: entity.licenseNumber,
      nationalId: entity.nationalId,
    );
  }
}