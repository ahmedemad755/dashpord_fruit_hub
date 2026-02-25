import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingApprovalView extends StatelessWidget {
  const PendingApprovalView({super.key});

  // دالة دايناميكية لفتح الروابط الخارجية (واتساب أو غيره)
  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("عذراً، تعذر فتح الرابط")));
      }
    }
  }

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
              await Prefs.setString("pharmacy_status", "pending");
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(BackendPoints.pharmacies)
              .doc(uId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(child: Text("حدث خطأ في الاتصال"));
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            // استخراج البيانات والحالة
            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final String status = data['status'] ?? 'pending';
            final String rejectionReason =
                data['rejectionReason'] ??
                "تم رفض طلبك لعدم استيفاء الشروط المطلوبة.";

            // تهيئة إعدادات الواجهة بناءً على الحالة (Dynamic Config)
            final config = _getStatusConfig(status, rejectionReason);

            // التحويل التلقائي عند القبول
            if (status == 'approved') {
              Future.microtask(() async {
                await Prefs.setString("pharmacy_status", "approved");
                if (context.mounted)
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Icon(
                      config.icon,
                      key: ValueKey(status),
                      size: 120,
                      color: config.color,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    config.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    config.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: status == 'rejected'
                          ? () => _launchExternalUrl(
                              context,
                              "https://wa.me/201121517143?text=استفسار بخصوص رفض الصيدلية",
                            )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config.btnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        config.btnText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (status == 'rejected') ...[
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted)
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                      },
                      child: const Text(
                        "العودة لتسجيل الدخول",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ميثود دايناميكية تفصل منطق الحالات عن الـ UI
  _StatusUIConfig _getStatusConfig(String status, String reason) {
    switch (status) {
      case 'approved':
        return _StatusUIConfig(
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          title: 'تم تفعيل حسابك!',
          subtitle: 'جاري تحويلك للوحة التحكم...',
          btnText: 'تمت الموافقة',
          btnColor: Colors.green,
        );
      case 'rejected':
        return _StatusUIConfig(
          icon: Icons.cancel_rounded,
          color: Colors.redAccent,
          title: 'عذراً، تم رفض الطلب',
          subtitle: reason,
          btnText: 'تواصل مع الدعم الفني',
          btnColor: Colors.redAccent,
        );
      default: // pending
        return _StatusUIConfig(
          icon: Icons.pending_actions_rounded,
          color: Colors.orangeAccent,
          title: 'طلبك قيد المراجعة الآن',
          subtitle:
              'فريق الإدارة يراجع أوراقك الآن، وسيتم فتح التطبيق لك تلقائياً فور الموافقة.',
          btnText: 'بانتظار الموافقة...',
          btnColor: Colors.grey[300]!,
        );
    }
  }
}

// كلاس مساعد لتخزين إعدادات كل حالة
class _StatusUIConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String btnText;
  final Color btnColor;

  _StatusUIConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.btnText,
    required this.btnColor,
  });
}
