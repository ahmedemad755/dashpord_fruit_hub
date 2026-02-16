// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/constants.dart';
import 'package:fruitesdashboard/core/errors/exceptions.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/firebase_auth_service.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/auth/data/models/user_model.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/user_entity.dart';

class AuthRepoImpl extends AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final DatabaseService databaseservice;
  final FireStoreService fireStoreService;

  AuthRepoImpl({
    required this.databaseservice,
    required this.firebaseAuthService,
    required this.fireStoreService,
  });

  @override
  Future<Either<Faliur, UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    User? user;
    try {
      // 1. إنشاء الحساب في Firebase Auth
      user = await firebaseAuthService.creatuserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userEntity = UserEntity(email: email, name: name, uId: user.uid);

      // 2. إضافة بيانات المستخدم إلى قاعدة البيانات (Firestore)
      await addUserData(user: userEntity, email: email);

      return Right(userEntity);
    } on CustomException catch (e) {
      // في حال فشل تخزين البيانات، نقوم بحذف الحساب من Auth لضمان نظافة البيانات
      await deletUser(user);
      return Left(ServerFaliur(e.message));
    } catch (e) {
      await deletUser(user);
      developer.log(
        'Error in createUser: ${e.toString()}',
        name: 'AuthRepoImpl',
      );
      return Left(ServerFaliur('فشل إنشاء الحساب، يرجى المحاولة لاحقاً.'));
    }
  }

  @override
  Future<Either<Faliur, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. تسجيل الدخول عبر البريد وكلمة المرور
      final user = await firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. جلب بيانات الصيدلي من قاعدة البيانات
      final userEntity = await getUserData(uid: user.uid);

      // 3. حفظ بيانات الجلسة محلياً (Shared Preferences)
      await saveUserData(user: userEntity);

      return Right(userEntity);
    } on CustomException catch (e) {
      return Left(ServerFaliur(e.message));
    } catch (e) {
      developer.log('Error in signIn: ${e.toString()}', name: 'AuthRepoImpl');
      return Left(ServerFaliur('حدث خطأ أثناء تسجيل الدخول.'));
    }
  }

  @override
  Future<Either<Faliur, void>> logout() async {
    try {
      // تسجيل الخروج من Firebase ومسح البيانات المحلية
      await firebaseAuthService.logout();
      await Prefs.remove(kUserData);
      return const Right(null);
    } on CustomException catch (e) {
      return Left(ServerFaliur(e.message));
    } catch (e) {
      developer.log('Logout Error: ${e.toString()}', name: 'AuthRepoImpl');
      return Left(ServerFaliur('خطأ تقني أثناء تسجيل الخروج.'));
    }
  }

  @override
  Future addUserData({
    required UserEntity user,
    bool useSet = false,
    required String email,
  }) async {
    final data = UserModel.fromEntity(user).toMap();
    if (useSet) {
      await databaseservice.setData(
        path: BackendPoints.addUserData,
        id: user.uId,
        data: data,
      );
    } else {
      await databaseservice.addData(
        path: BackendPoints.addUserData,
        data: data,
        documentId: user.uId,
      );
    }
  }

  @override
  Future<UserEntity> getUserData({required String uid}) async {
    final userData = await databaseservice.getData(
      path: BackendPoints.getUserData,
      docuementId: uid,
    );
    // تحويل البيانات القادمة من Map إلى Entity
    return UserModel.fromJson(userData[0] as Map<String, dynamic>);
  }

  @override
  Future saveUserData({required UserEntity user}) async {
    final jsonData = jsonEncode(UserModel.fromEntity(user).toMap());
    await Prefs.setString(kUserData, jsonData);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    await firebaseAuthService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
      onVerificationCompleted: onVerificationCompleted,
      onAutoRetrievalTimeout: onAutoRetrievalTimeout,
    );
  }

  @override
  Future<UserCredential> verifySmsCode(String smsCode) async {
    return await firebaseAuthService.verifySmsCode(smsCode);
  }

  // دالة مساعدة لحذف المستخدم من Auth في حال فشل إكمال التسجيل في قاعدة البيانات
  Future<void> deletUser(User? user) async {
    if (user != null) {
      await firebaseAuthService.deleteUser();
    }
  }
}
