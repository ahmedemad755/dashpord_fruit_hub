import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_state.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/Dash_board_body.dart';

class DashBoardView extends StatelessWidget {
  const DashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. الحصول على الـ uId للمستخدم الحالي
    final String? uId = FirebaseAuth.instance.currentUser?.uid;

    return BlocListener<PharmacyLoginCubit, PharmacyLoginState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }

        if (state is LogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          // ✅ عرض اسم الصيدلية واسم الصيدلي أيضاً إذا أردت
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pharmacies')
                .doc(uId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("جاري التحميل...");
              }

              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;

                // استخراج البيانات بناءً على الصورة التي أرسلتها
                String pharmacyName =
                    data['pharmacyName'] ?? "صيدلية غير معروفة";
                String pharmacistName = data['pharmacistName'] ?? "";

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "صيدلية $pharmacyName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (pharmacistName.isNotEmpty)
                      Text(
                        "د/ $pharmacistName",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                );
              }

              return const Text("لوحة التحكم");
            },
          ),
        ),
        body: const DashBoardBody(),
      ),
    );
  }
}
