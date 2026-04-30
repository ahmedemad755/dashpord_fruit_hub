import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';

class AccountDisabledException implements Exception {
  const AccountDisabledException();

  String get message =>
      '403 Forbidden: تم تعطيل حسابك، يرجى التواصل مع الإدارة';
}

class AccountStatusService {
  AccountStatusService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  static bool isDisabledStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'disabled' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'inactive' ||
        normalized == 'blocked' ||
        normalized == 'إلغاء' ||
        normalized == 'الغاء' ||
        normalized == 'ملغي' ||
        normalized == 'ملغى';
  }

  static bool isRejectedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'rejected' || normalized == 'reject';
  }

  static bool canWriteWithStatus(String status) {
    return status.trim().toLowerCase() == 'approved';
  }

  Future<String> getCurrentStatus(String pharmacyId) async {
    final snapshot = await _firestore
        .collection(BackendPoints.pharmacies)
        .doc(pharmacyId)
        .get(const GetOptions(source: Source.server));

    return snapshot.data()?['status']?.toString() ?? 'disabled';
  }

  Future<void> ensureAccountCanWrite(String pharmacyId) async {
    final status = await getCurrentStatus(pharmacyId);
    if (!canWriteWithStatus(status)) {
      throw const AccountDisabledException();
    }
  }

  Future<void> forceLogoutDisabledAccount() async {
    await _firebaseAuth.signOut();
    await Prefs.remove('kUserData');
    await Prefs.remove('pharmacy_status');
    await Prefs.remove('isLoggedIn');
    await Prefs.remove('user_role');
    await Prefs.remove('userRole');
    await Prefs.remove('userPassword');
  }
}
