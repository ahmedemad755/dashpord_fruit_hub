import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';
import 'package:fruitesdashboard/core/services/support_contact_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';

class PendingApprovalView extends StatefulWidget {
  const PendingApprovalView({super.key});

  @override
  State<PendingApprovalView> createState() => _PendingApprovalViewState();
}

class _PendingApprovalViewState extends State<PendingApprovalView> {
  final SupportContactService _supportContactService = SupportContactService();
  bool _isOpeningSupport = false;
  bool _didNavigateHome = false;
  bool _didNavigateLogin = false;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await Prefs.setString('pharmacy_status', 'pending');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _openSupportWhatsApp() async {
    if (_isOpeningSupport) return;

    setState(() => _isOpeningSupport = true);

    try {
      final launched = await _supportContactService.openSupportWhatsApp();

      if (!mounted) return;
      if (!launched) {
        _showSnackBar('رقم الدعم غير متوفر حاليا');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('تعذر جلب رقم الدعم حاليا');
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningSupport = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateHomeWhenApproved() {
    if (_didNavigateHome) return;
    _didNavigateHome = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Prefs.setString('pharmacy_status', 'approved');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uId = FirebaseAuth.instance.currentUser?.uid;

    if (uId == null && !_didNavigateLogin) {
      _didNavigateLogin = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ),
        body: uId == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection(BackendPoints.pharmacies)
                    .doc(uId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('حدث خطأ في الاتصال'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.data() ?? {};
                  final status = data['status']?.toString() ?? 'pending';
                  final rejectionReason =
                      data['rejectionReason']?.toString() ??
                          'تم رفض طلبك لعدم استيفاء الشروط المطلوبة.';
                  final config = _getStatusConfig(status, rejectionReason);

                  if (status == 'approved') {
                    _navigateHomeWhenApproved();
                  }

                  return _PendingApprovalContent(
                    config: config,
                    status: status,
                    isOpeningSupport: _isOpeningSupport,
                    onSupportPressed: _openSupportWhatsApp,
                    onLogoutPressed: _logout,
                  );
                },
              ),
      ),
    );
  }

  _StatusUIConfig _getStatusConfig(String status, String reason) {
    switch (status) {
      case 'approved':
        return const _StatusUIConfig(
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
          title: 'عذرا، تم رفض الطلب',
          subtitle: reason,
          btnText: 'تواصل مع الدعم الفني',
          btnColor: Colors.redAccent,
        );
      default:
        return _StatusUIConfig(
          icon: Icons.pending_actions_rounded,
          color: Colors.orangeAccent,
          title: 'طلبك قيد المراجعة الآن',
          subtitle:
              'فريق الإدارة يراجع أوراقك الآن، وسيتم فتح التطبيق لك تلقائيا فور الموافقة.',
          btnText: 'بانتظار الموافقة...',
          btnColor: Colors.grey[300]!,
        );
    }
  }
}

class _PendingApprovalContent extends StatelessWidget {
  const _PendingApprovalContent({
    required this.config,
    required this.status,
    required this.isOpeningSupport,
    required this.onSupportPressed,
    required this.onLogoutPressed,
  });

  final _StatusUIConfig config;
  final String status;
  final bool isOpeningSupport;
  final VoidCallback onSupportPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
              onPressed: status == 'rejected' && !isOpeningSupport
                  ? onSupportPressed
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: config.btnColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isOpeningSupport
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
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
              onPressed: onLogoutPressed,
              child: const Text(
                'العودة لتسجيل الدخول',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusUIConfig {
  const _StatusUIConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.btnText,
    required this.btnColor,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String btnText;
  final Color btnColor;
}
