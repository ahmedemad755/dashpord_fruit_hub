import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/pharmacy_entity.dart';

abstract class PharmacyAuthRepo {
  // إنشاء حساب صيدلية جديد مع كل البيانات المطلوبة
  Future<Either<Faliur, PharmacyEntity>> signUpPharmacy({
    required String email,
    required String password,
    required String pharmacyName,
    required String phoneNumber,
    required String address,
    required String licenseUrl,
    required String pharmacistName,
    required String pharmacistId,
    required String licenseNumber,
    required String nationalId,
  });

  // تسجيل دخول الصيدلية وفحص الحالة (Approved/Pending)
  Future<Either<Faliur, PharmacyEntity>> signInPharmacy({
    required String email,
    required String password,
  });

  // تسجيل الخروج
  Future<Either<Faliur, void>> logout();

  // جلب بيانات الصيدلية من Firestore
  Future<PharmacyEntity> getPharmacyData({required String uId});

  // حفظ البيانات محلياً (Shared Preferences)
  Future<void> savePharmacyData({required PharmacyEntity pharmacy});

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String) onCodeSent,
    required void Function(String) onAutoRetrievalTimeout,
  });
}
