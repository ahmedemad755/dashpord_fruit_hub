part of 'pharmacy_signup_cubit.dart';

abstract class PharmacySignupState extends Equatable {
  const PharmacySignupState();

  @override
  List<Object?> get props => [];
}

class PharmacySignupInitial extends PharmacySignupState {}

class PharmacySignupLoading extends PharmacySignupState {}

class PharmacySignupSuccess extends PharmacySignupState {
  final PharmacyEntity pharmacyEntity;
  // أضفنا رسالة نجاح مخصصة لتوضيح أن الحساب قيد المراجعة
  final String message;

  const PharmacySignupSuccess({
    required this.pharmacyEntity,
    this.message = 'تم استلام طلبك بنجاح، وهو قيد المراجعة الآن.',
  });

  @override
  List<Object?> get props => [pharmacyEntity, message];
}

class PharmacySignupFailure extends PharmacySignupState {
  final String message;

  const PharmacySignupFailure(this.message);

  @override
  List<Object?> get props => [message];
}
