import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/editProductView.dart';

class ProductsCategoryView extends StatelessWidget {
  const ProductsCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentPharmacyId =
        FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // خلفية أفتح وأكثر راحة
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "إدارة المخزون والعروض",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(BackendPoints.getProducts)
            .where('pharmacyId', isEqualTo: currentPharmacyId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // تجميع المنتجات
          Map<String, List<QueryDocumentSnapshot>> groupedProducts = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            String category = data['category'] ?? "منتجات عامة";
            groupedProducts.putIfAbsent(category, () => []).add(doc);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedProducts.keys.length,
            itemBuilder: (context, index) {
              String category = groupedProducts.keys.elementAt(index);
              List<QueryDocumentSnapshot> products = groupedProducts[category]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(
                    side: BorderSide.none,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${products.length} منتجات مسجلة",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  children: products
                      .map((product) => _buildProductItem(context, product))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    bool hasDiscount = data['hasDiscount'] ?? false;

    // --- منطق تنبيه المخزون ---
    num amount = data['unitAmount'] ?? 0;
    Color stockColor;
    String stockStatus;

    if (amount <= 5) {
      stockColor = Colors.red; // خطر: نفاد الكمية
      stockStatus = "مخزون منخفض جداً";
    } else if (amount <= 10) {
      stockColor = Colors.orange; // تحذير: شارف على الانتهاء
      stockStatus = "بدأ ينفد";
    } else {
      stockColor = Colors.green; // آمن: الكمية متوفرة
      stockStatus = "متوفر";
    }

    return Column(
      children: [
        const Divider(height: 1, indent: 70),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(data['imageurl'] ?? ""),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // نقطة ملونة تشير للحالة فوق صورة المنتج
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: stockColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            data['name'] ?? "",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${data['price']} \$",
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // عرض حالة المخزون بنص صغير وملون
                  Text(
                    "($stockStatus: $amount)",
                    style: TextStyle(
                      color: stockColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "خصم فعال: ${data['discountPercentage']}%",
                    style: const TextStyle(color: Colors.orange, fontSize: 11),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  hasDiscount ? Icons.local_offer : Icons.local_offer_outlined,
                  color: hasDiscount ? Colors.orange : Colors.grey.shade400,
                ),
                onPressed: () => _showDiscountDialog(
                  context,
                  doc.reference,
                  hasDiscount,
                  data['discountPercentage'],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.blueAccent,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProductView(productId: doc.id, initialData: data),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "لا توجد منتجات مضافة حالياً",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- دالة الخصم تظل كما هي مع تحسين بسيط في الألوان ---
  void _showDiscountDialog(
    BuildContext context,
    DocumentReference ref,
    bool hasDiscount,
    dynamic current,
  ) {
    final controller = TextEditingController(
      text: hasDiscount ? current.toString() : "",
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("إعداد خصم للمنتج"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "نسبة الخصم %",
            hintText: "مثلاً: 15",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.update({'hasDiscount': false, 'discountPercentage': 0});
              Navigator.pop(context);
            },
            child: const Text("حذف الخصم", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              int? val = int.tryParse(controller.text);
              if (val != null && val <= 100) {
                ref.update({'hasDiscount': true, 'discountPercentage': val});
                Navigator.pop(context);
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
