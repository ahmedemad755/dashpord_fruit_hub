import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OTPState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OTPInitial extends OTPState {}

class OTPLoading extends OTPState {}

class OTPCodeSent extends OTPState {
  final String verificationId;

  OTPCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class OTPVerified extends OTPState {
  final User? user;

  OTPVerified(this.user);
}

class OTPError extends OTPState {
  final String message;

  OTPError(this.message);

  @override
  List<Object?> get props => [message];
}
