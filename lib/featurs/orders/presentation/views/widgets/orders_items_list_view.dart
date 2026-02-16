import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/order_item.dart';

class OrdersItemsListView extends StatelessWidget {
  const OrdersItemsListView({super.key, required this.orderentEntites});

  final List<OrderEntity> orderentEntites;

  @override
  Widget build(BuildContext context) {
    // 1. تجميع الأوردرات بناءً على uId المستخدم
    final Map<String, List<OrderEntity>> groupedOrders = {};

    for (var order in orderentEntites) {
      if (groupedOrders.containsKey(order.uId)) {
        groupedOrders[order.uId]!.add(order);
      } else {
        groupedOrders[order.uId] = [order];
      }
    }

    // 2. عرض القائمة المجمعة
    return ListView.builder(
      itemCount: groupedOrders.keys.length,
      itemBuilder: (context, index) {
        String userId = groupedOrders.keys.elementAt(index);
        List<OrderEntity> userOrders = groupedOrders[userId]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ExpansionTile(
            shape: const Border(), // إزالة الخطوط الافتراضية للـ ExpansionTile
            title: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'جاري تحميل بيانات العميل...',
                    style: TextStyle(fontSize: 14),
                  );
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return Text(
                    'العميل: ${userData['name'] ?? 'بدون اسم'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  );
                }
                return Text('ID العميل: $userId');
              },
            ),
            subtitle: Text(
              'عدد الطلبات: ${userOrders.length}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            children: userOrders.map((order) {
              return OrderItemWidget(orderentEntites: order);
            }).toList(),
          ),
        );
      },
    );
  }
}
