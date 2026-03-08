import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/order_item.dart';

class OrdersItemsListView extends StatelessWidget {
  const OrdersItemsListView({super.key, required this.orderentEntites});
  final List<OrderEntity> orderentEntites;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<OrderEntity>> groupedOrders = {};
    for (var order in orderentEntites) {
      String id = order.uId.isEmpty ? 'unknown' : order.uId;
      groupedOrders.putIfAbsent(id, () => []).add(order);
    }

    if (groupedOrders.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Text("لا توجد طلبات حالياً"),
      ));
    }

    // ✅ نستخدم ListView للكل لضمان عدم حدوث Overflow عند فتح التوسعة (Expansion)
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedOrders.keys.length,
      itemBuilder: (context, index) => _buildCustomerCard(context, groupedOrders, index),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Map<String, List<OrderEntity>> groupedOrders, int index) {
    String userId = groupedOrders.keys.elementAt(index);
    List<OrderEntity> userOrders = groupedOrders[userId]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        maintainState: true, // يحافظ على حالة الفتح
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: const Icon(Icons.person, color: Colors.teal),
        ),
        title: _buildUserName(userId),
        subtitle: Text('عدد الطلبات: ${userOrders.length}'),
        children: [
          // ✅ إزالة الـ SizedBox ذو الارتفاع الثابت 300 واستبداله بـ ListView مرن
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userOrders.length,
            itemBuilder: (context, i) => OrderItemWidget(orderentEntites: userOrders[i]),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildUserName(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Text("...");
        if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Text(userData['name'] ?? 'عميل غير معروف', style: const TextStyle(fontWeight: FontWeight.bold));
        }
        return Text('عميل ID: ${userId.substring(0, 5)}...');
      },
    );
  }
}