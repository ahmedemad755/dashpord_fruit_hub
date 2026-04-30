import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/manger/update_order/update_order_cubit.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_product_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/product_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد فيرستور مباشرة

class PrescriptionPricingDialog extends StatelessWidget {
  final OrderEntity orderEntity;
  const PrescriptionPricingDialog({super.key, required this.orderEntity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text(
            "تسعير الروشتة وإضافة الأدوية",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          // 1. عرض صورة الروشتة
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.network(
                  orderEntity.prescriptionImage!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => 
                      const Center(child: Text("تعذر تحميل الصورة")),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. قائمة الأدوية المضافة حالياً
          Expanded(
            flex: 2,
            child: BlocBuilder<UpdateOrderCubit, UpdateOrderState>(
              builder: (context, state) {
                List<OrderProductEntity> tempItems = [];
                double total = 0.0;

                if (state is UpdateOrderProductsChanged) {
                  tempItems = state.tempProducts;
                  total = state.totalPrice;
                }

                if (tempItems.isEmpty) {
                  return const Center(child: Text("لم يتم إضافة أدوية بعد"));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: tempItems.length,
                        itemBuilder: (context, index) => ListTile(
                          leading: const Icon(Icons.medication, color: Colors.teal),
                          title: Text(tempItems[index].name),
                          subtitle: Text("الكمية: ${tempItems[index].quantity}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${tempItems[index].price * tempItems[index].quantity} ج.م"),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => context
                                    .read<UpdateOrderCubit>()
                                    .removeProductFromOrder(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("الإجمالي:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("$total ج.م",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3. أزرار التحكم
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // 🔥 الحل العبقري: هنجيب المنتجات من فيرستور مباشرة هنا عشان نتخطى مشكلة الكيوبت
                    final snapshot = await FirebaseFirestore.instance
                        .collection('products')
                        .where('pharmacyId', isEqualTo: orderEntity.pharmacyId) // جلب منتجات الصيدلية دي بس
                        .get();

                    final products = snapshot.docs.map((doc) {
                      final data = doc.data();
                      return OrderProductEntity(
                        name: data['name'] ?? '',
                        code: data['code'] ?? '',
                        imageUrl: data['imageurl'] ?? '',
                        price: (data['price'] as num?)?.toDouble() ?? 0.0,
                        quantity: 1,
                      );
                    }).toList();

                    if (context.mounted) {
                      final selectedProduct = await showSearch<OrderProductEntity?>(
                        context: context,
                        delegate: ProductSearchDelegate(products), 
                      );

                      if (selectedProduct != null && context.mounted) {
                        context.read<UpdateOrderCubit>().addProductToOrder(selectedProduct);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("إضافة صنف"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                     // 1. خزن الـ Cubit في متغير قبل الـ pop عشان الـ context هيروح
  final updateCubit = context.read<UpdateOrderCubit>();
  
  // 2. اقفل الـ Dialog فوراً (ده بيخلي الـ UI يستقر)
  Navigator.pop(context);
                    updateCubit.confirmAndShipPrescription(
                          orderID: orderEntity.orderID,
                          pharmacyId: orderEntity.pharmacyId!,
                        );
                   
                  },
                  child: const Text("تأكيد وشحن الآن", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}