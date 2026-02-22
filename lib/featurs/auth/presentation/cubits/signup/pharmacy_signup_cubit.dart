import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo.dart';

import '../../../domain/entites/pharmacy_entity.dart';

part 'pharmacy_signup_state.dart';

class PharmacySignupCubit extends Cubit<PharmacySignupState> {
  final PharmacyAuthRepo pharmacyAuthRepo;

  PharmacySignupCubit(this.pharmacyAuthRepo) : super(PharmacySignupInitial());

  Future<void> createPharmacy({
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
    emit(PharmacySignupLoading());

    final result = await pharmacyAuthRepo.signUpPharmacy(
      email: email,
      password: password,
      pharmacyName: pharmacyName,
      phoneNumber: phoneNumber,
      address: address,
      licenseUrl: licenseUrl,
      pharmacistName: pharmacistName,
      pharmacistId: pharmacistId,
      licenseNumber: licenseNumber,
      nationalId: nationalId,
    );

    result.fold((failure) => emit(PharmacySignupFailure(failure.message)), (
      pharmacyEntity,
    ) async {
      try {
        // حفظ البيانات الأساسية للتحقق من الحالة عند إعادة فتح التطبيق
        await Prefs.setBool("isLoggedIn", true);
        await Prefs.setString("userRole", "pharmacy");

        // ملاحظة: حفظ الباسورد محلياً اختيار أمني حساس، يفضل استخدامه فقط للضرورة
        await Prefs.setString("userPassword", password);

        emit(PharmacySignupSuccess(pharmacyEntity: pharmacyEntity));
      } catch (e) {
        emit(const PharmacySignupFailure("فشل حفظ بيانات الدخول المحلية."));
      }
    });
  }
}
