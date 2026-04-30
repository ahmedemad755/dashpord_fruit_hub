import 'package:flutter/material.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_product_entety.dart';

class ProductSearchDelegate extends SearchDelegate<OrderProductEntity?> {
  final List<OrderProductEntity> allProducts;

  ProductSearchDelegate(this.allProducts);

  // تخصيص شكل خانة البحث
  @override
  String get searchFieldLabel => 'ابحث بكود الصنف...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // مسح نص البحث
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // إغلاق البحث بدون اختيار
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // تصفية المنتجات بناءً على الكود (Code)
    final results = allProducts.where((product) {
      return product.code.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // تصفية الاقتراحات أثناء الكتابة بناءً على الكود
    final suggestions = allProducts.where((product) {
      return product.code.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(suggestions);
  }

  // ودجت مشتركة لعرض النتائج
  Widget _buildSearchResults(List<OrderProductEntity> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text("لا يوجد صنف بهذا الكود"),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Image.network(
            product.imageUrl,
            width: 50,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.medication),
          ),
          title: Text(product.name),
          subtitle: Text("كود: ${product.code}"),
          trailing: Text("${product.price} ج.م"),
          onTap: () {
            close(context, product); // إرجاع الصنف المختار للـ Dialog
          },
        );
      },
    );
  }
}