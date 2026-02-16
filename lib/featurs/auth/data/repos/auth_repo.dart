import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/user_entity.dart';

abstract class AuthRepo {
  // إنشاء حساب جديد
  Future<Either<Faliur, UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  // تسجيل الدخول بالبريد وكلمة المرور
  Future<Either<Faliur, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // إضافة بيانات المستخدم لقاعدة البيانات
  Future addUserData({
    required UserEntity user,
    bool useSet = false,
    required String email,
  });

  // حفظ بيانات المستخدم محلياً
  Future saveUserData({required UserEntity user});

  // جلب بيانات المستخدم من قاعدة البيانات
  Future<UserEntity> getUserData({required String uid});

  // تسجيل الخروج
  Future<Either<Faliur, void>> logout();

  // التحقق من رقم الهاتف
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  });

  // تأكيد كود التحقق (SMS)
  Future<UserCredential> verifySmsCode(String smsCode);
}