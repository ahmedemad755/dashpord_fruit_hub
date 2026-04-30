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
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/Dash_board_body.dart';// تأكد من صحة مسارات الـ SensorCubit والـ State في مشروعimport 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_cubit.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_cubit.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_state.dart';

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
            _buildRolePicker(context),
          ],
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pharmacies')
                .doc(uId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر وهمي أو مساحة فارغة لموازنة الـ AppBar لأن الـ Actions تأخذ مساحة جهة اليمين
                    const SizedBox(width: 48), 
                    
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "صيدلية ${data['pharmacyName'] ?? ""}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                      ),
                    ),

                    // عرض بيانات الحساس (درجة الحرارة والرطوبة)
                    _buildLiveSensorWidget(),
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

  /// ويدجيت عرض الحساس المختصرة في الـ AppBar
  Widget _buildLiveSensorWidget() {
    return BlocBuilder<SensorCubit, SensorState>(
      builder: (context, state) {
        if (state is SensorDataUpdated) {
          // تغيير اللون للأحمر إذا زادت الحرارة عن 28 درجة مئوية (تنبيه للصيدلية)
          final bool isWarning = state.sensorData.temperature > 28;
          final Color statusColor = isWarning ? Colors.red : Colors.green;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thermostat, size: 14, color: statusColor),
                    Text(
                      "${state.sensorData.temperature.toStringAsFixed(1)}°",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isWarning ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop, size: 14, color: Colors.blue),
                    Text(
                      "${state.sensorData.humidity.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        // حالة التحميل أو عدم وجود بيانات بعد
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
          ),
        );
      },
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
    if (role == UserRole.employee) {
      context.read<RoleCubit>().setRole(role);
      return;
    }

    final controller = TextEditingController();
    String requiredPin = "";
    String roleTitle = "";

    if (role == UserRole.manager) {
      requiredPin = "1111";
      roleTitle = "المدير العام";
    } else if (role == UserRole.warehouseManager) {
      requiredPin = "2222";
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