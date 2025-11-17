import 'package:flutter/widgets.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/order_item.dart';

class OrdersItemsListView extends StatelessWidget {
  const OrdersItemsListView({super.key, required this.orderentEntites});

  final List<OrderEntity> orderentEntites;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orderentEntites.length,
      itemBuilder: (context, index) {
        return OrderItemWidget(orderentEntites: orderentEntites[index]);
      },
    );
  }
}
