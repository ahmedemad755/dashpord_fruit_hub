import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';

class ProductsCategoryView extends StatelessWidget {
  const ProductsCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
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
        // التأكد من جلب البيانات من كولكشن products
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
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

            // قراءة الكاتيجوري (لو مش موجود نكتب تصنيف غير محدد)
            String category = data['categoryName'] ?? "تصنيف عام";

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

              return _buildCategorySection(category, products);
            },
          );
        },
      ),
    );
  }

  // ويدجت لعرض الكاتيجوري والمنتجات اللي جواه
  Widget _buildCategorySection(
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

          // الحسابات (بناءً على الموديل بتاعك)
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
                horizontal: 16,
                vertical: 10,
              ),
              leading: _buildProductImage(data['imageurl']),
              title: Text(
                data['name'] ?? "منتج بدون اسم",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildPriceWidget(price, finalPrice, hasDiscount),
                  const SizedBox(height: 6),
                  // عرض اسم الصيدلية من الحقل pharmacyId اللي في الكود بتاعك
                  _buildPharmacyBadge(data['pharmacyId'] ?? "صيدلية غير مسجلة"),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "الكمية",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    "${data['unitAmount'] ?? 0}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: (url != null && url.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          : const Icon(Icons.medication_rounded, color: AppColors.primaryColor),
    );
  }

  Widget _buildPriceWidget(num oldPrice, num finalPrice, bool hasDiscount) {
    return Row(
      children: [
        Text(
          "${finalPrice.toStringAsFixed(1)} \$",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            "$oldPrice \$",
            style: const TextStyle(
              color: Colors.red,
              decoration: TextDecoration.lineThrough,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPharmacyBadge(String pharmacyName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_pharmacy_outlined,
            size: 12,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            pharmacyName,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
}
