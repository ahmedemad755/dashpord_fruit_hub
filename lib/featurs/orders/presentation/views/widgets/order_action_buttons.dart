import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/manger/update_order/update_order_cubit.dart';

class OrderActionButtons extends StatelessWidget {
  const OrderActionButtons({
    super.key,
    required this.orderEntity,
    required this.orderID,
  });

  final OrderEntity orderEntity;
  final String orderID;

  @override
  Widget build(BuildContext context) {
    // إخفاء الأزرار تماماً إذا تم التوصيل أو الإلغاء
    if (orderEntity.status == OrderStatus.delivered ||
        orderEntity.status == OrderStatus.canceled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Divider(height: 24),
        Row(
          children: [
            // زر المرحلة التالية
            Expanded(flex: 2, child: _buildMainAction(context)),

            // زر الإلغاء يظهر فقط في حالة الانتظار (قبل الشحن)
            if (orderEntity.status == OrderStatus.pending) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  label: "إلغاء",
                  icon: Icons.cancel_outlined,
                  color: Colors.redAccent,
                  onPressed: () => _updateStatus(context, OrderStatus.canceled),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // تحديد الزر الرئيسي بناءً على الحالة الحالية
  Widget _buildMainAction(BuildContext context) {
    if (orderEntity.status == OrderStatus.pending) {
      return _buildActionButton(
        context,
        label: "تأكيد وشحن الطلب",
        icon: Icons.local_shipping_outlined,
        color: Colors.teal,
        onPressed: () => _updateStatus(context, OrderStatus.shipped),
      );
    } else if (orderEntity.status == OrderStatus.shipped) {
      return _buildActionButton(
        context,
        label: "تأكيد التوصيل والاستلام",
        icon: Icons.check_circle_outline,
        color: Colors.green,
        onPressed: () => _updateStatus(context, OrderStatus.delivered),
      );
    }
    return const SizedBox.shrink();
  }

  // دالة مساعدة لتنفيذ التحديث عبر الـ Cubit
  void _updateStatus(BuildContext context, OrderStatus newStatus) {
    context.read<UpdateOrderCubit>().updateOrder(
      status: newStatus,
      orderID: orderID,
      orderEntity: orderEntity,
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
