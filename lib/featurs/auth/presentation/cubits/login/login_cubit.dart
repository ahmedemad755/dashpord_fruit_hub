import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo authRepo;

  LoginCubit(this.authRepo) : super(LoginInitial());

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());

    final result = await authRepo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold((failure) => emit(LoginFailure(failure.message)), (
      userEntity,
    ) async {
      try {
        // حفظ حالة الدخول وبيانات المستخدم محلياً
        await Prefs.setBool("isLoggedIn", true);
        await Prefs.setString("userPassword", password);

        emit(LoginSuccess(userEntity: userEntity));
      } catch (e) {
        emit(LoginFailure("حدث خطأ أثناء حفظ بيانات الجلسة"));
      }
    });
  }

  // تسجيل الخروج
  Future<void> logout() async {
    emit(LogoutLoading());

    try {
      final result = await authRepo.logout();

      result.fold((failure) => emit(LogoutFailure(failure.message)), (
        success,
      ) async {
        // تنظيف البيانات المحلية عند تسجيل الخروج بنجاح
        await Prefs.remove("isLoggedIn");
        await Prefs.remove("userPassword");

        emit(LogoutSuccess());
      });
    } catch (e) {
      emit(LogoutFailure("حدث خطأ غير متوقع: $e"));
    }
  }
}
