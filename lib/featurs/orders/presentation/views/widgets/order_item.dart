import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/order_action_buttons.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderEntity orderentEntites;
  const OrderItemWidget({super.key, required this.orderentEntites});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قيمة الطلب: \$${orderentEntites.totalPrice}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              _buildStatusBadge(orderentEntites), // تمرير الكيان بالكامل لفحص حقول إضافية
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(Icons.location_on, "الاسم",
              orderentEntites.shippingAddressModel.name ?? "لا يوجد اسم"),
          _buildInfoRow(Icons.location_on, "العنوان",
              orderentEntites.shippingAddressModel.address ?? "لا يوجد عنوان"),
              
          _buildInfoRow(Icons.payment, "الدفع",
              _getPaymentMethodArabic(orderentEntites.paymentMethod)),
          _buildInfoRow(Icons.phone, "رقم الهاتف", orderentEntites.shippingAddressModel.phone ?? "غير متوفر"),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم المنتجات
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("المنتجات:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    ...orderentEntites.orderProducts.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text("• ${p.name} (x${p.quantity})",
                                  style: const TextStyle(fontSize: 12)),
                              if (p.isPrescriptionRequired)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.assignment_late,
                                      size: 14, color: Colors.red),
                                ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              // قسم الروشتة
              if (orderentEntites.prescriptionImage != null &&
                  orderentEntites.prescriptionImage!.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => _showZoomedImage(
                        context, orderentEntites.prescriptionImage!),
                    child: Column(
                      children: [
                        const Text("الروشتة",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              orderentEntites.prescriptionImage!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2));
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image,
                                      color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("إضغط للتكبير",
                            style: TextStyle(fontSize: 9, color: Colors.blue)),
                      ],
                    ),
                  ),
                )
              else if (orderentEntites.orderProducts
                  .any((p) => p.isPrescriptionRequired))
                const Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 24),
                      Text("الروشتة مفقودة!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.orange)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          OrderActionButtons(
            orderEntity: orderentEntites,
            orderID: orderentEntites.orderID,
          ),
        ],
      ),
    );
  }

  void _showZoomedImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("فحص الروشتة الطبية",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text("$label: ",
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderEntity order) {
    Color color;
    String statusText;

    switch (order.status) {
      case OrderStatus.delivered:
        color = Colors.green;
        statusText = "تم التوصيل";
        break;
      case OrderStatus.canceled:
        color = Colors.red;
        // فحص من قام بالإلغاء بناءً على البيانات القادمة من Firestore
        // ملاحظة: تأكد أن OrderEntity يحتوي على حقل cancelledBy أو قم بالوصول إليه من الموديل
        if (order.cancelledBy == 'customer') {
          statusText = "ألغاه العميل";
        } else {
          statusText = "ملغي";
        }
        break;
      case OrderStatus.shipped:
        color = Colors.blue;
        statusText = "تم الشحن";
        break;
      case OrderStatus.pending:
      default:
        color = Colors.orange;
        statusText = "قيد الانتظار";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPaymentMethodArabic(String method) =>
      method.toLowerCase() == 'cash' ? 'كاش' : 'بطاقة ائتمان';
}