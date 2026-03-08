import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/enums/user_enum.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_state.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/roles/role_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/Dash_board_body.dart';

class DashBoardView extends StatelessWidget {
  const DashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
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
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            _buildRolePicker(context), // زر تبديل الصلاحيات
          ],
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pharmacies')
                .doc(uId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    Text(
                      "صيدلية ${data['pharmacyName'] ?? ""}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    BlocBuilder<RoleCubit, UserRole>(
                      builder: (context, role) => Text(
                        _getRoleArabicName(role),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey,
                        ),
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

  Widget _buildRolePicker(BuildContext context) {
    return PopupMenuButton<UserRole>(
      icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.teal),
      onSelected: (role) => _verifyAndSetRole(context, role),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: UserRole.manager,
          child: Text("وضع المدير (كامل)"),
        ),
        const PopupMenuItem(
          value: UserRole.warehouseManager,
          child: Text("وضع مدير المخزن"),
        ),
        const PopupMenuItem(
          value: UserRole.employee,
          child: Text("وضع موظف عادي"),
        ),
      ],
    );
  }

  void _verifyAndSetRole(BuildContext context, UserRole role) {
    // إذا اختار وضع الموظف، لا نحتاج لرمز سري
    if (role == UserRole.employee) {
      context.read<RoleCubit>().setRole(role);
      return;
    }

    final controller = TextEditingController();

    // تحديد الرمز المطلوب واللقب بناءً على الاختيار
    String requiredPin = "";
    String roleTitle = "";

    if (role == UserRole.manager) {
      requiredPin = "1111"; // الرمز الخاص بالمدير العام
      roleTitle = "المدير العام";
    } else if (role == UserRole.warehouseManager) {
      requiredPin = "2222"; // الرمز الخاص بمدير المخزن
      roleTitle = "مدير المخزن";
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("تأكيد هوية $roleTitle", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("يرجى إدخال الرمز السري المخصص لهذه الصلاحية"),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: InputDecoration(
                hintText: "****",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (controller.text == requiredPin) {
                context.read<RoleCubit>().setRole(role);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("تم التبديل إلى وضع $roleTitle بنجاح"),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("الرمز السري غير صحيح!")),
                );
              }
            },
            child: const Text("دخول"),
          ),
        ],
      ),
    );
  }

  String _getRoleArabicName(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return "صلاحية: مدير عام";
      case UserRole.warehouseManager:
        return "صلاحية: مدير مخزن";
      case UserRole.employee:
        return "صلاحية: موظف";
    }
  }
}
