import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/editProductView.dart';

class ProductsCategoryView extends StatelessWidget {
  const ProductsCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب الـ ID الخاص بالصيدلية الحالية
    final String currentPharmacyId =
        FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9), // خلفية أهدى ومريحة للعين
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "جرد المنتجات المتاحة",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // فلترة المنتجات حسب الصيدلية الحالية
        stream: FirebaseFirestore.instance
            .collection('products')
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

          // تجميع المنتجات بناءً على الكاتيجوري
          Map<String, List<QueryDocumentSnapshot>> groupedProducts = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            String category = data['category'] ?? "تصنيف عام";

            if (groupedProducts[category] == null) {
              groupedProducts[category] = [];
            }
            groupedProducts[category]!.add(doc);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: groupedProducts.keys.length,
            itemBuilder: (context, index) {
              String category = groupedProducts.keys.elementAt(index);
              List<QueryDocumentSnapshot> products = groupedProducts[category]!;

              return _buildCategorySection(context, category, products);
            },
          );
        },
      ),
    );
  }

  // ويدجت لعرض الكاتيجوري والمنتجات اللي جواه
  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<QueryDocumentSnapshot> products,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        iconColor: AppColors.primaryColor,
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.darkBlue,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          "متوفر: ${products.length} منتجات",
          style: const TextStyle(fontSize: 12),
        ),
        children: products.map((product) {
          final data = product.data() as Map<String, dynamic>;

          // الحسابات
          num price = data['price'] ?? 0;
          bool hasDiscount = data['hasDiscount'] ?? false;
          num discountPercent = data['discountPercentage'] ?? 0;
          num finalPrice = hasDiscount
              ? price - (price * (discountPercent / 100))
              : price;

          return Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: _buildProductImage(data['imageurl']),
              title: Text(
                data['name'] ?? "منتج بدون اسم",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildPriceWidget(price, finalPrice, hasDiscount),
                  const SizedBox(height: 6),
                  _buildPharmacyBadge(data['pharmacyId'] ?? "صيدلية غير مسجلة"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // عرض الكمية
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "الكمية",
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      Text(
                        "${data['unitAmount'] ?? 0}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // زر التعديل
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => EditProductView(
                            productId: product.id,
                            initialData: data,
                          ),
                        ),
                      );
                    },
                  ),
                  // زر الحذف
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showEnhancedDeleteDialog(
                      context,
                      product.id,
                      data['name'] ?? "هذا المنتج",
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductImage(String? url) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: (url != null && url.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            )
          : const Icon(
              Icons.medication_rounded,
              color: AppColors.primaryColor,
              size: 25,
            ),
    );
  }

  Widget _buildPriceWidget(num oldPrice, num finalPrice, bool hasDiscount) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "${finalPrice.toStringAsFixed(1)} \$",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 6),
          Text(
            "$oldPrice \$",
            style: const TextStyle(
              color: Colors.red,
              decoration: TextDecoration.lineThrough,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPharmacyBadge(String pharmacyName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        pharmacyName,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "لا توجد منتجات مضافة",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _showEnhancedDeleteDialog(
    BuildContext context,
    String productId,
    String productName,
  ) {
    final TextEditingController confirmationController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          // نحتاج StatefulBuilder لتحديث حالة الزر داخل الديالوج
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 10),
                  const Text(
                    "إجراء أمني",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "لحذف ($productName) نهائياً، يرجى كتابة كلمة 'حذف' في الحقل أدناه:",
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: confirmationController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "اكتب 'حذف' هنا",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      onChanged: (value) {
                        // تحديث حالة الزر عند الكتابة
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text(
                    "إلغاء",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmationController.text == "حذف"
                        ? Colors.red
                        : Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // لا يعمل الزر إلا إذا كانت الكلمة صحيحة
                  onPressed: confirmationController.text == "حذف"
                      ? () async {
                          Navigator.of(dialogContext).pop();
                          _executeDelete(context, productId, productName);
                        }
                      : null,
                  child: const Text(
                    "تأكيد الحذف النهائي",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // دالة التنفيذ الفعلية للحذف
  Future<void> _executeDelete(
    BuildContext context,
    String productId,
    String productName,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم حذف $productName بنجاح"),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشلت عملية الحذف، حاول مجدداً")),
        );
      }
    }
  }
}
