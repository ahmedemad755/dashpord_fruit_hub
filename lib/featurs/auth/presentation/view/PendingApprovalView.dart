import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';

class PendingApprovalView extends StatelessWidget {
  const PendingApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uId = FirebaseAuth.instance.currentUser?.uid;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // عند تسجيل الخروج نمسح الحالة المخزنة لضمان نظافة البيانات
              await Prefs.setString("pharmacy_status", "pending");
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pharmacies')
              .doc(uId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("حدث خطأ في الاتصال"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            bool isApproved = false;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                isApproved =
                    data['isApproved'] == true || data['status'] == 'approved';

                // 🔥 الفلو التلقائي: بمجرد تغيير الحالة في الداتابيز، يتم التحويل فوراً
                if (isApproved) {
                  Future.microtask(() async {
                    await Prefs.setString("pharmacy_status", "approved");
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    }
                  });
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Icon(
                      isApproved
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      key: ValueKey(isApproved),
                      size: 120,
                      color: isApproved ? Colors.green : Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    isApproved ? 'تم تفعيل حسابك!' : 'طلبك قيد المراجعة الآن',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isApproved
                        ? 'جاري تحويلك للوحة التحكم...'
                        : 'شكراً لانضمامك. فريق الإدارة يراجع أوراقك الآن، وسيتم فتح التطبيق لك تلقائياً فور الموافقة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: null, // معطل لأن التحويل أصبح تلقائياً بالكامل
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApproved
                            ? AppColors.primary
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        isApproved ? 'تمت الموافقة' : 'بانتظار الموافقة...',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
