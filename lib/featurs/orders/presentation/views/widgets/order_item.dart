import 'package:cloud_firestore/cloud_firestore.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السعر الإجمالي + الحالة
            Row(
              children: [
                Text(
                  'إجمالي السعر: \$${orderentEntites.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _getStatusColor(orderentEntites.status),
                  ),
                  child: Text(
                    _getStatusArabicName(orderentEntites.status),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // بيانات العميل (الاسم والإيميل)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(orderentEntites.uId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'جاري تحميل بيانات العميل...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Cairo',
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'العميل: ${userData['name'] ?? 'اسم غير مسجل'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'البريد: ${userData['email'] ?? 'لا يوجد بريد'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return Text(
                  'معرف المستخدم: ${orderentEntites.uId}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                );
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'عنوان الشحن:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              orderentEntites.shippingAddressModel.toString(),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text(
                  'طريقة الدفع: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  _getPaymentMethodArabic(orderentEntites.paymentMethod),
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(),
            const Text(
              'المنتجات المطلوبة:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              itemCount: orderentEntites.orderProducts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = orderentEntites.orderProducts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.medication),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'الكمية: ${product.quantity} | سعر الوحدة: \$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    '\$${(product.price * product.quantity).toStringAsFixed(2)}',
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

  // دالة مساعدة لترجمة حالة الطلب
  String _getStatusArabicName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.canceled:
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  // دالة مساعدة لتحديد لون الحالة
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade200;
      case OrderStatus.shipped:
        return Colors.blue.shade200;
      case OrderStatus.delivered:
        return Colors.green.shade200;
      case OrderStatus.canceled:
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  // دالة مساعدة لتعريب طريقة الدفع
  String _getPaymentMethodArabic(String method) {
    if (method.toLowerCase() == 'cash') return 'نقداً عند الاستلام';
    if (method.toLowerCase() == 'card') return 'بطاقة ائتمان';
    return method; // إرجاع القيمة كما هي إذا لم تكن كاش أو كارت
  }
}
