import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';

class DashboardAnalyticsView extends StatefulWidget {
  const DashboardAnalyticsView({super.key});

  @override
  State<DashboardAnalyticsView> createState() => _DashboardAnalyticsViewState();
}

class _DashboardAnalyticsViewState extends State<DashboardAnalyticsView> {
  String selectedFilter = 'Daily';

  DateTime getStartDate() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter) {
      case 'Daily':
        return today;
      case 'Weekly':
        return today.subtract(const Duration(days: 7));
      case 'Monthly':
        return DateTime(now.year, now.month - 1, now.day);
      case 'Yearly':
        return DateTime(now.year, 1, 1);
      default:
        return today;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentPharmacyId =
        FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "التحليلات والمبيعات",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // التعديل: فلترة الطلبات حسب الصيدلية الحالية
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('pharmacyId', isEqualTo: currentPharmacyId)
            .snapshots(),
        builder: (context, ordersSnapshot) {
          if (ordersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          final allOrders = ordersSnapshot.data?.docs ?? [];
          DateTime startDate = getStartDate();

          // فلترة الطلبات بناءً على التاريخ فقط
          final filteredOrders = allOrders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String? dateStr = data['date'];
            if (dateStr == null) return false;

            DateTime? orderDate = DateTime.tryParse(dateStr);
            if (orderDate == null) return false;

            return orderDate.isAfter(startDate) ||
                orderDate.isAtSameMomentAs(startDate);
          }).toList();

          double deliveredSales = 0;
          int deliveredCount = 0;
          int cancelledCount = 0;
          int pendingCount = 0;

          for (var doc in filteredOrders) {
            final data = doc.data() as Map<String, dynamic>;
            final String status = (data['status'] ?? 'pending')
                .toString()
                .toLowerCase();
            final double price = (data['totalPrice'] ?? 0).toDouble();

            if (status == 'delivered') {
              deliveredSales += price;
              deliveredCount++;
            } else if (status == 'canceled' || status == 'cancelled') {
              cancelledCount++;
            } else {
              pendingCount++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("تحديد النطاق الزمني"),
                const SizedBox(height: 12),
                _buildTimeFilter(),
                const SizedBox(height: 25),
                _buildSectionTitle("أداء المبيعات (${_getArabicFilterName()})"),
                const SizedBox(height: 15),
                _buildStatGrid(
                  currentPharmacyId: currentPharmacyId,
                  totalOrders: filteredOrders.length,
                  deliveredSales: deliveredSales,
                  deliveredCount: deliveredCount,
                  cancelled: cancelledCount,
                  pending: pendingCount,
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getArabicFilterName() {
    if (selectedFilter == 'Daily') return "اليوم";
    if (selectedFilter == 'Weekly') return "الأسبوع";
    if (selectedFilter == 'Monthly') return "الشهر";
    return "السنة";
  }

  Widget _buildTimeFilter() {
    final filters = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
    return Row(
      children: filters.map((filter) {
        bool isSelected = selectedFilter == filter;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  _translateFilter(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkgrey600,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _translateFilter(String filter) {
    switch (filter) {
      case 'Daily':
        return "اليوم";
      case 'Weekly':
        return "الأسبوع";
      case 'Monthly':
        return "الشهر";
      case 'Yearly':
        return "السنة";
      default:
        return "";
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBlue,
      ),
    );
  }

  Widget _buildStatGrid({
    required String currentPharmacyId,
    required int totalOrders,
    required double deliveredSales,
    required int deliveredCount,
    required int cancelled,
    required int pending,
  }) {
    return StreamBuilder<QuerySnapshot>(
      // التعديل: فلترة المنتجات حسب الصيدلية الحالية لحساب "إجمالي الأصناف"
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('pharmacyId', isEqualTo: currentPharmacyId)
          .snapshots(),
      builder: (context, prodSnapshot) {
        int productCount = prodSnapshot.hasData
            ? prodSnapshot.data!.docs.length
            : 0;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              "مبيعات الفترة",
              "${deliveredSales.toStringAsFixed(0)} \$",
              Icons.payments_rounded,
              AppColors.successGradient,
            ),
            _buildStatCard(
              "طلبات ناجحة",
              deliveredCount.toString(),
              Icons.verified_rounded,
              AppColors.accentGradient2,
            ),
            _buildStatCard(
              "قيد المعالجة",
              pending.toString(),
              Icons.pending_actions_rounded,
              AppColors.accentGradient1,
            ),
            _buildStatCard(
              "ملغي/مرتجع",
              cancelled.toString(),
              Icons.cancel_presentation_rounded,
              const LinearGradient(
                colors: [Color(0xFFEF5350), Color(0xFFC62828)],
              ),
            ),
            _buildStatCard(
              "إجمالي الأصناف",
              productCount.toString(),
              Icons.inventory_rounded,
              AppColors.accentGradient3,
            ),
            _buildStatCard(
              "إجمالي الطلبات",
              totalOrders.toString(),
              Icons.analytics_rounded,
              const LinearGradient(
                colors: [AppColors.primaryColor, AppColors.darkBlue],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
