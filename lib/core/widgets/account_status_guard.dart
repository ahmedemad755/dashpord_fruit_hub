import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_state.dart';

class AccountStatusGuard extends StatelessWidget {
  const AccountStatusGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return child;
    }

    return BlocProvider(
      create: (_) => getIt<PharmacyLoginCubit>()..watchPharmacyStatus(uid),
      child: BlocListener<PharmacyLoginCubit, PharmacyLoginState>(
        listener: (context, state) {
          if (state is AccountDisabledLogout) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              'login',
              (route) => false,
            );
          }
        },
        child: child,
      ),
    );
  }
}
