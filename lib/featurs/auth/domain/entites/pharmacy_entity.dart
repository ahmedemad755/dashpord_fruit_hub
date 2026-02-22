import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyEntity {
  final String uId;
  final String pharmacyName;
  final String email;
  final String phoneNumber;
  final String address;
  final String licenseUrl;
  final String status;
  final String role;
  final DateTime createdAt;
  // الحقول الجديدة
  final String pharmacistName;
  final String pharmacistId;
  final String licenseNumber;
  final String nationalId;

  PharmacyEntity({
    required this.uId,
    required this.pharmacyName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.licenseUrl,
    required this.status,
    required this.role,
    required this.createdAt,
    required this.pharmacistName,
    required this.pharmacistId,
    required this.licenseNumber,
    required this.nationalId,
  });
  // إضافة هذه الدالة لتحويل البيانات من Firestore
  factory PharmacyEntity.fromJson(Map<String, dynamic> json) {
    return PharmacyEntity(
      uId: json['uId'] ?? '',
      pharmacyName: json['pharmacyName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      licenseUrl: json['licenseUrl'] ?? '',
      status: json['status'] ?? 'pending',
      role: json['role'] ?? 'pharmacy',
      // تحويل Timestamp الخاص بفايربيز إلى DateTime
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      pharmacistName: json['pharmacistName'] ?? '',
      pharmacistId: json['pharmacistId'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      nationalId: json['nationalId'] ?? '',
    );
  }
}
