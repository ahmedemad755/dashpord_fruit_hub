import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/pharmacy_entity.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_state.dart';

class PharmacyLoginCubit extends Cubit<PharmacyLoginState> {
  final PharmacyAuthRepo pharmacyAuthRepo;
  StreamSubscription<DocumentSnapshot>? _pharmacySubscription;

  PharmacyLoginCubit(this.pharmacyAuthRepo) : super(PharmacyLoginInitial());

  // تسجيل دخول الصيدلية
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(PharmacyLoginLoading());
    try {
      // 1. تسجيل الدخول في Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // 2. التحقق هل هو صيدلي فعلاً؟
      var pharmacyDoc = await FirebaseFirestore.instance
          .collection('pharmacies') // تأكد من اسم الكولكشن عندك
          .doc(userCredential.user!.uid)
          .get();

      if (pharmacyDoc.exists) {
        // صيدلي حقيقي
        final pharmacyData = PharmacyEntity.fromJson(pharmacyDoc.data()!);
        await Prefs.setString("pharmacy_status", pharmacyData.status);
        await Prefs.setBool("isLoggedIn", true);
        emit(PharmacyLoginSuccess(pharmacyEntity: pharmacyData));
      } else {
        // إيميل صحيح في Auth ولكنه "مستخدم عادي" وليس صيدلي
        await FirebaseAuth.instance.signOut(); // اطرده فوراً
        emit(PharmacyLoginFailure("عذراً، هذا الحساب ليس مسجلاً كصيدلية"));
      }
    } catch (e) {
      emit(PharmacyLoginFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    print("Log: تم بدء عملية تسجيل الخروج..."); // تتبع الاستدعاء
    emit(LogoutLoading());

    try {
      final result = await pharmacyAuthRepo.logout();
      if (isClosed) return;
      result.fold(
        (failure) {
          print("Log: فشل تسجيل الخروج: ${failure.message}"); // تتبع الفشل
          emit(LogoutFailure(failure.message));
        },
        (success) async {
          // ✅ مسح حالة الدخول عند الخروج بنجاح
          await Prefs.setBool("isLoggedIn", false);
          print("Log: تم مسح حالة الدخول من Prefs");
          emit(LogoutSuccess());
        },
      );
    } catch (e) {
      print("Log: حدث خطأ غير متوقع: $e");
      emit(LogoutFailure("حدث خطأ غير متوقع: $e"));
      print("FULL ERROR: $e");
    }
  }

  void watchPharmacyStatus(String uId) {
    // إلغاء أي اشتراك قديم لتجنب تكرار العمليات
    _pharmacySubscription?.cancel();

    _pharmacySubscription = FirebaseFirestore.instance
        .collection('pharmacies')
        .doc(uId)
        .snapshots() // 👈 السر هنا: snapshots بدلاً من get
        .listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final pharmacyData = PharmacyEntity.fromJson(snapshot.data()!);

            // تحديث الحالة محلياً في Prefs لضمان استمرارها
            Prefs.setString("pharmacy_status", pharmacyData.status);

            // إرسال الحالة الجديدة للواجهة فوراً
            emit(PharmacyLoginSuccess(pharmacyEntity: pharmacyData));

            print("Log: تم تحديث الحالة لحظياً إلى: ${pharmacyData.status}");
          }
        });
  }

  // لا تنسى إغلاق الـ Stream عند تدمير الـ Cubit
  @override
  Future<void> close() {
    _pharmacySubscription?.cancel();
    return super.close();
  }
}
