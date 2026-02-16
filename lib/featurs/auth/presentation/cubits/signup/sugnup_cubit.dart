import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/user_entity.dart';

part 'sugnup_state.dart';

class SugnupCubit extends Cubit<SugnupState> {
  final AuthRepo authRepo;

  SugnupCubit(this.authRepo) : super(SugnupInitial());

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(SugnupLoading());

    // ملاحظة: تم حذف fetchSignInMethodsForEmail لأنها لم تعد مدعومة رسمياً
    // الـ AuthRepo الآن يتعامل مع فحص تكرار الإيميل تلقائياً أثناء التسجيل

    final result = await authRepo.createUserWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );

    await result.fold(
      (failure) {
        emit(SugnupFailure(failure.message));
      },
      (userEntity) async {
        try {
          // حفظ حالة الدخول وكلمة المرور محلياً
          await Prefs.setBool("isLoggedIn", true);
          await Prefs.setString("userPassword", password);

          emit(SugnupSuccess(userEntity: userEntity));
        } catch (e) {
          emit(SugnupFailure("تم التسجيل ولكن فشل حفظ البيانات المحلية."));
        }
      },
    );
  }
}
