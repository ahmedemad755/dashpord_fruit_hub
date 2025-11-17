import 'package:flutter/material.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/orders_items_list_view.dart';

import 'filter_section.dart';

class OrdersViewBody extends StatelessWidget {
  const OrdersViewBody({super.key, required this.orders});
  final List<OrderEntity> orders;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // ✅ يحدد constraints للـ ScrollView
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FilterSection(),
                const SizedBox(height: 24),
                Expanded(child: OrdersItemsListView(orderentEntites: orders)),
              ],
            ),
          ),
        );
      },
    );
  }
}
