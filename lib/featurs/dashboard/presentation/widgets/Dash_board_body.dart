import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/enums/user_enum.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_state.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/roles/role_cubit.dart'; // التأكد من استيراد الكوبيت الجديد

class DashBoardBody extends StatelessWidget {
  const DashBoardBody({super.key});

  @override
  Widget build(BuildContext context) {
    // حساب عرض الشاشة لتحديد التصميم
    double screenWidth = MediaQuery.of(context).size.width;

    // إعدادات التجاوب (Responsive Settings)
    int crossAxisCount;
    double horizontalPadding;
    double childAspectRatio;

    if (screenWidth > 1100) {
      // شاشات الكمبيوتر الكبيرة (Desktop)
      crossAxisCount = 4;
      horizontalPadding = screenWidth * 0.1; // هوامش جانبية واسعة
      childAspectRatio = 1.3;
    } else if (screenWidth > 700) {
      // شاشات التابلت (Tablet)
      crossAxisCount = 3;
      horizontalPadding = 40;
      childAspectRatio = 1.2;
    } else {
      // شاشات الموبايل (Mobile)
      crossAxisCount = 2;
      horizontalPadding = 16;
      childAspectRatio = 1.1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // لون خلفية هادئ للويب
      body: BlocBuilder<RoleCubit, UserRole>(
        builder: (context, currentRole) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // قسم الترحيب والعنوان
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    48,
                    horizontalPadding,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "لوحة التحكم",
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "إدارة العمليات اليومية للصيدلية",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // شبكة الأدوات الرئيسية (Responsive Grid)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildDashboardCard(
                      context,
                      title: "إضافة منتج",
                      icon: Icons.add_business_rounded,
                      color: Colors.blue,
                      route: AppRoutes.addProduct,
                      // السماح فقط للمدير ومدير المخزن
                      isEnabled: currentRole != UserRole.warehouseManager,
                    ),
                    _buildOrdersCard(context, currentRole),
                    _buildDashboardCard(
                      context,
                      title: "التحليلات",
                      icon: Icons.analytics_rounded,
                      color: Colors.purple,
                      route: AppRoutes.DashboardAnalytics,
                      // السماح فقط للمدير
                      isEnabled: currentRole == UserRole.manager,
                    ),
                    _buildDashboardCard(
                      context,
                      title: "الأصناف",
                      icon: Icons.category_rounded,
                      color: Colors.teal,
                      route: AppRoutes.productsCategory,
                      isEnabled: true, // متاح للجميع
                    ),
                    _buildDashboardCard(
                      context,
                      title: "المخزون",
                      icon: Icons.inventory_rounded,
                      color: Colors.indigo,
                      route: AppRoutes.inventory,
                      // السماح فقط للمدير ومدير المخزن
                      isEnabled: currentRole != UserRole.employee,
                    ),
                    _buildDashboardCard(
                      context,
                      title: "العروض",
                      icon: Icons.local_offer_rounded,
                      color: Colors.pink,
                      route: AppRoutes.offersManagement,
                      isEnabled: currentRole == UserRole.manager,
                    ),
                  ]),
                ),
              ),

              // قسم زر تسجيل الخروج
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? screenWidth * 0.3 : 32,
                    vertical: 60,
                  ),
                  child: BlocBuilder<PharmacyLoginCubit, PharmacyLoginState>(
                    builder: (context, state) {
                      return _buildLogoutButton(context, state);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // دالة بناء كارت طلبات العملاء (الاستماع المباشر من Firestore)
Widget _buildOrdersCard(BuildContext context, UserRole currentRole) {
  // 1. جلب معرف الصيدلية الحالية
  final String currentPharmacyId = FirebaseAuth.instance.currentUser?.uid ?? "";

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('orders')
        .where('pharmacyId', isEqualTo: currentPharmacyId) // ✅ فلترة حسب الصيدلية
        .where('status', isEqualTo: 'pending')            // ✅ فلترة الحالات المعلقة فقط
        .snapshots(),
    builder: (context, snapshot) {
      String? badgeCount;
      
      if (snapshot.hasData) {
        // الـ count الآن سيمثل فقط طلبات هذه الصيدلية المعلقة
        int count = snapshot.data!.docs.length;
        badgeCount = count > 0 ? count.toString() : null;
      }

      return _buildDashboardCard(
        context,
        title: "طلبات العملاء",
        icon: Icons.shopping_basket_rounded,
        color: Colors.orange,
        route: AppRoutes.orders,
        badge: badgeCount,
        isEnabled: currentRole != UserRole.warehouseManager,
      );
    },
  );
}

  // ويدجت بناء الكارت الموحد
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    String? badge,
    bool isEnabled = true, // إضافة باراميتر التفعيل
  }) {
    return InkWell(
      onTap: isEnabled
          ? () => Navigator.pushNamed(context, route)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("عذراً، لا تملك صلاحية الوصول لهذه الميزة"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
      borderRadius: BorderRadius.circular(20),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5, // تقليل الوضوح إذا كان غير مفعّل
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEnabled
                            ? icon
                            : Icons.lock_outline, // تغيير الأيقونة للقفل
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null && isEnabled)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت زر تسجيل الخروج
  Widget _buildLogoutButton(BuildContext context, PharmacyLoginState state) {
    if (state is LogoutLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.red.shade100),
        ),
      ),
      onPressed: () => _showLogoutConfirmation(context),
      icon: const Icon(Icons.logout_rounded),
      label: const Text(
        "تسجيل الخروج من النظام",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // حوار تأكيد الخروج
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تنبيه الخروج", textAlign: TextAlign.right),
        content: const Text(
          "هل تريد حقاً مغادرة لوحة التحكم؟",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<PharmacyLoginCubit>().logout();
                }
              });
            },
            child: const Text(
              "تأكيد الخروج",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
