import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_state.dart';

class OTPCubit extends Cubit<OTPState> {
  final AuthRepo authRepo;
  String? currentPhoneNumber;
  String? verificationId;
  String? lastSmsCode;
  String? newPassword;

  OTPCubit(this.authRepo) : super(OTPInitial());

  /// إرسال كود التحقق
  Future<void> sendOTP(String phoneNumber) async {
    print('رقم الهاتف اللي وصل لـ Cubit: "$phoneNumber"');
    if (phoneNumber.isEmpty) {
      emit(OTPError('الرقم لا يمكن أن يكون فارغًا'));
      return;
    }
    currentPhoneNumber = phoneNumber;
    emit(OTPLoading());

    await authRepo.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onVerificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          final user = userCredential.user;

          if (user != null) {
            emit(OTPVerified(user));
          } else {
            emit(OTPError('فشل التحقق التلقائي'));
          }
        } catch (e) {
          emit(OTPError('فشل التحقق التلقائي'));
        }
      },

      onVerificationFailed: (FirebaseAuthException e) {
        emit(OTPError(e.message ?? 'حدث خطأ أثناء إرسال الكود'));
      },
      onCodeSent: (String verId) {
        verificationId = verId;
        emit(OTPCodeSent(verId));
      },
      onAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        emit(OTPCodeSent(verId)); // ممكن نعيد نفس الحالة
      },
    );
  }

  /// تأكيد الكود المُدخل من المستخدم
  Future<void> verifyCode(String smsCode) async {
    if (verificationId == null) {
      emit(OTPError('حدث خطأ: لا يوجد verificationId'));
      return;
    }

    try {
      emit(OTPLoading());

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null && user.phoneNumber != null) {
        emit(OTPVerified(user));
      } else {
        emit(OTPError("فشل التحقق من الكود"));
      }
    } on FirebaseAuthException catch (e) {
      emit(OTPError(e.message ?? 'حدث خطأ أثناء التحقق من الكود'));
    }
  }
}
