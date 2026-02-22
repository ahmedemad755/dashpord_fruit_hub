import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/constants.dart';
import 'package:fruitesdashboard/core/errors/exceptions.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/firebase_auth_service.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/auth/data/models/pharmacy_model.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/pharmacy_entity.dart';

class PharmacyAuthRepoImpl extends PharmacyAuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final DatabaseService databaseService;

  PharmacyAuthRepoImpl({
    required this.firebaseAuthService,
    required this.databaseService,
  });

  @override
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
  }) async {
    User? user;
    try {
      user = await firebaseAuthService.creatuserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final pharmacyEntity = PharmacyEntity(
        uId: user.uid,
        pharmacyName: pharmacyName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        licenseUrl: licenseUrl,
        pharmacistName: pharmacistName,
        pharmacistId: pharmacistId,
        licenseNumber: licenseNumber,
        nationalId: nationalId,
        status: 'pending',
        role: 'pharmacy',
        createdAt: DateTime.now(),
      );

      await databaseService.addData(
        path: BackendPoints.pharmacies,
        data: PharmacyModel.fromEntity(pharmacyEntity).toJson(),
        documentId: user.uid,
      );

      return Right(pharmacyEntity);
    } on CustomException catch (e) {
      if (user != null) await firebaseAuthService.deleteUser();
      return Left(ServerFaliur(e.message));
    } catch (e) {
      if (user != null) await firebaseAuthService.deleteUser();
      return Left(ServerFaliur('حدث خطأ أثناء إنشاء حساب الصيدلية'));
    }
  }

  @override
  Future<Either<Faliur, PharmacyEntity>> signInPharmacy({
    required String email,
    required String password,
  }) async {
    try {
      final user = await firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final pharmacyEntity = await getPharmacyData(uId: user.uid);

      await savePharmacyData(pharmacy: pharmacyEntity);

      return Right(pharmacyEntity);
    } on CustomException catch (e) {
      return Left(ServerFaliur(e.message));
    } catch (e) {
      return Left(ServerFaliur('فشل تسجيل الدخول، تأكد من البيانات'));
    }
  }

  @override
  Future<PharmacyEntity> getPharmacyData({required String uId}) async {
    final data = await databaseService.getData(
      path: BackendPoints.pharmacies,
      docuementId: uId,
    );
    return PharmacyModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> savePharmacyData({required PharmacyEntity pharmacy}) async {
    final jsonData = jsonEncode(PharmacyModel.fromEntity(pharmacy).toJson());
    await Prefs.setString(kUserData, jsonData);
  }

  @override
  Future<Either<Faliur, void>> logout() async {
    try {
      await firebaseAuthService.logout();
      await Prefs.remove(kUserData);
      return const Right(null);
    } catch (e) {
      print('#################Pharmacy Logout Error: ${e.toString()}');
      return Left(ServerFaliur('خطأ أثناء تسجيل الخروج'));
    }
  }

  // ✅ التنفيذ الفعلي لـ verifyPhoneNumber
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String) onCodeSent,
    required void Function(String) onAutoRetrievalTimeout,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
        onVerificationCompleted(phoneAuthCredential);
      },
      verificationFailed: (FirebaseAuthException error) {
        onVerificationFailed(error);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onAutoRetrievalTimeout(verificationId);
      },
      timeout: const Duration(seconds: 60),
    );
  }
}
