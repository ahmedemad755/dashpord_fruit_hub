import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_state.dart';

class DashBoardBody extends StatelessWidget {
  const DashBoardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addProduct);
            },
            label: "إضافة منتج جديد",
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.orders);
            },
            label: "عرض طلبات العملاء",
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.DashboardAnalytics);
            },
            label: "التحليلات والإحصائيات",
          ),

          const SizedBox(height: 16),

          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.productsCategory);
            },
            label: "عرض المنتجات حسب التصنيف",
          ),

          const SizedBox(height: 16),

          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.bannersManagement);
            },
            label: "إدارة عروض السلايدر",
          ),
          const SizedBox(height: 32), // مسافة أكبر لتمييز زر الخروج
          BlocBuilder<PharmacyLoginCubit, PharmacyLoginState>(
            builder: (context, state) {
              return _buildLogoutButton(context, state);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("تسجيل الخروج", textAlign: TextAlign.right),
        content: const Text("هل أنت متأكد؟", textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              // استخدام addPostFrameCallback يحل مشكلة Dirty Widget
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<PharmacyLoginCubit>().logout();
                }
              });
            },
            child: const Text("خروج", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, PharmacyLoginState state) {
    return Center(
      child: state is LogoutLoading
          ? const CircularProgressIndicator(color: Colors.red)
          : Builder(
              builder: (buttonContext) => ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showLogoutConfirmation(buttonContext),
                icon: const Icon(Icons.logout),
                label: const Text("تسجيل الخروج الآن"),
              ),
            ),
    );
  }
}
