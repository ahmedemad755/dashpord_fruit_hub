import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/manger/update_order/update_order_cubit.dart';

import '../../../../../core/enums/order_enum.dart';

class OrderActionButtons extends StatelessWidget {
  const OrderActionButtons({super.key, required this.orderEntity});

  final OrderEntity orderEntity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Visibility(
          visible: orderEntity.status == OrderStatus.pending,
          child: ElevatedButton(
            onPressed: () {
              context.read<UpdateOrderCubit>().updateOrder(
                status: OrderStatus.shipped,
                orderID: orderEntity.orderID,
              );
            },
            child: const Text('تاكيد'),
          ),
        ),
        Visibility(
          visible: orderEntity.status == OrderStatus.pending,
          child: ElevatedButton(
            onPressed: () {
              // استدعاء الكوبت لتحديث حالة الطلب إلى canceled
              context.read<UpdateOrderCubit>().updateOrder(
                status: OrderStatus.canceled,
                orderID: orderEntity.orderID,
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red, // Optional: خلي لون الزر أحمر
            ),
            child: const Text('رفض'),
          ),
        ),

        Visibility(
          visible: orderEntity.status == OrderStatus.shipped,
          child: ElevatedButton(
            onPressed: () {
              context.read<UpdateOrderCubit>().updateOrder(
                status: OrderStatus.delivered,
                orderID: orderEntity.orderID,
              );
            },
            child: const Text('تم التوصيل'),
          ),
        ),
      ],
    );
  }
}
