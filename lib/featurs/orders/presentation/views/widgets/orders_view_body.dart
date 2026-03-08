import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/const/dashboardPageTemplate.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/orders_items_list_view.dart';

import 'filter_section.dart';

class OrdersViewBody extends StatelessWidget {
  const OrdersViewBody({super.key, required this.orders});
  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    return DashboardPageTemplate(
      title: "إدارة الطلبات",
      subtitle: "استعرض طلبات العملاء وحدث حالات الشحن والتوصيل",
      content: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FilterSection(),
            const SizedBox(height: 24),
            // ✅ يتم تمرير القائمة كاملة هنا
            OrdersItemsListView(orderentEntites: orders),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}