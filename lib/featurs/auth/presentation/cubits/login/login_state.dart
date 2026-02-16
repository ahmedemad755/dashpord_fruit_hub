import 'package:equatable/equatable.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/user_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => []; // استخدام Object? للسماح بالقيم الفارغة
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity userEntity;

  const LoginSuccess({required this.userEntity});

  @override
  List<Object?> get props => [userEntity]; // أضف المتغير هنا لضمان عمل Equatable
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ حالات تسجيل الخروج الجديدة
class LogoutLoading extends LoginState {}

class LogoutSuccess extends LoginState {}

class LogoutFailure extends LoginState {
  final String message;
  const LogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
