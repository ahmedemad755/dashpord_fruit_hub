import 'package:equatable/equatable.dart' show Equatable;
import 'package:fruitesdashboard/featurs/auth/domain/entites/pharmacy_entity.dart';

abstract class PharmacyLoginState extends Equatable {
  const PharmacyLoginState();

  @override
  List<Object?> get props => [];
}

class PharmacyLoginInitial extends PharmacyLoginState {}

class PharmacyLoginLoading extends PharmacyLoginState {}

class PharmacyLoginSuccess extends PharmacyLoginState {
  final PharmacyEntity pharmacyEntity;

  const PharmacyLoginSuccess({required this.pharmacyEntity});

  @override
  List<Object?> get props => [pharmacyEntity];
}

class PharmacyLoginFailure extends PharmacyLoginState {
  final String message;

  const PharmacyLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// حالات تسجيل الخروج
// ✅ حالات تسجيل الخروج الجديدة
class LogoutLoading extends PharmacyLoginState {}

class LogoutSuccess extends PharmacyLoginState {}

class AccountDisabledLogout extends PharmacyLoginState {
  final String message;

  const AccountDisabledLogout({
    this.message = 'عذراً، تم تعطيل حسابك، يرجى التواصل مع الإدارة',
  });

  @override
  List<Object?> get props => [message];
}

class LogoutFailure extends PharmacyLoginState {
  final String message;
  const LogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
