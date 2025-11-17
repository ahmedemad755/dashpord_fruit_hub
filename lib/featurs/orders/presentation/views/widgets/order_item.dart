import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/order_action_buttons.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderEntity orderentEntites;
  const OrderItemWidget({super.key, required this.orderentEntites});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Price + Status
            Row(
              children: [
                Text(
                  'Total Price: \$${orderentEntites.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: orderentEntites.status == OrderStatus.pending
                        ? Colors.orange
                        : orderentEntites.status == OrderStatus.shipped
                        ? Colors.yellowAccent
                        : orderentEntites.status == OrderStatus.delivered
                        ? Colors.green
                        : Colors.red,
                  ),
                  child: Text(
                    orderentEntites.status.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'User ID: ${orderentEntites.uId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            const Text(
              'Shipping Address:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              orderentEntites.shippingAddressModel.toString(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),

            Text(
              'Payment Method: ${orderentEntites.paymentMethod}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // ✅ ListView.builder داخل Column لازم يكون shrinkWrap
            ListView.builder(
              itemCount: orderentEntites.orderProducts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // منع Scroll داخلي
              itemBuilder: (context, index) {
                final product = orderentEntites.orderProducts[index];
                return ListTile(
                  leading: Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    'Quantity: ${product.quantity} | Price: \$${product.price.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    'total: \$${(product.price * product.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            OrderActionButtons(orderEntity: orderentEntites),
          ],
        ),
      ),
    );
  }
}
