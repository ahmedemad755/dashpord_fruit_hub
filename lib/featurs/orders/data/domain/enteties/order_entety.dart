import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_product_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/shipping_address_entety.dart';

class OrderEntity {
  final double totalPrice;
  final String uId;
  final String orderID;
  final String? pharmacyId; // 👈 إضافة الحقل هنا
  final ShippingAddressEntity shippingAddressModel;
  final List<OrderProductEntity> orderProducts;
  final String paymentMethod;
  final String? prescriptionImage;
  final OrderStatus status;
  final String? prescriptionImageUrl;



  OrderEntity({
    required this.totalPrice,
    required this.uId,
    required this.orderID,
    this.pharmacyId, // 👈 إضافته للـ Constructor
    required this.status,
    required this.shippingAddressModel,
    required this.orderProducts,
    required this.paymentMethod,
      this.prescriptionImageUrl,
      this.prescriptionImage
  });
}