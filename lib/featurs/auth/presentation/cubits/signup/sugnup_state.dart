part of 'sugnup_cubit.dart';

abstract class SugnupState extends Equatable {
  const SugnupState();

  @override
  List<Object> get props => [];
}

class SugnupInitial extends SugnupState {}

class SugnupLoading extends SugnupState {}

class SugnupSuccess extends SugnupState {
  final UserEntity userEntity;
  final String successMessage;

  const SugnupSuccess({
    required this.userEntity,
    this.successMessage = 'تم إنشاء الحساب بنجاح',
  });

  @override
  List<Object> get props => [userEntity, successMessage];
}

class SugnupFailure extends SugnupState {
  final String message;

  const SugnupFailure(this.message);

  @override
  List<Object> get props => [message];
}
