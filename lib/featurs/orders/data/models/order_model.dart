import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/models/order_product_model.dart';
import 'package:fruitesdashboard/featurs/orders/data/models/shipping_address_model.dart';

class OrderModel {
  final String? id;
  final DateTime? date;
  final String? status;
  final double totalPrice;
  final String uId;
  final ShippingAddressModel shippingAddressModel;
  final List<OrderProductModel> orderProducts;
  final String paymentMethod;
  final String orderID;
  final String pharmacyId;
  final String? pharmacyName;
  final String? prescriptionImage;
  final String? cancelledBy;

  const OrderModel({
    this.id,
    this.date,
    this.status,
    required this.totalPrice,
    required this.uId,
    required this.shippingAddressModel,
    required this.orderProducts,
    required this.paymentMethod,
    required this.orderID,
    required this.pharmacyId,
    this.pharmacyName,
    this.prescriptionImage,
    this.cancelledBy,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return OrderModel(
      id: id ?? json['id']?.toString(),
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : json['date'] is String
              ? DateTime.tryParse(json['date'].toString().replaceFirst(' ', 'T'))
              : null,
      prescriptionImage: json['prescriptionImage']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      cancelledBy: json['cancelledBy']?.toString(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      uId: json['uId']?.toString() ?? '',
      pharmacyId: json['pharmacyId']?.toString() ?? '',
      pharmacyName: json['pharmacyName'],
      shippingAddressModel: ShippingAddressModel.fromJson(
        json['shippingAddressModel'] is Map
            ? Map<String, dynamic>.from(json['shippingAddressModel'])
            : <String, dynamic>{},
      ),
      orderProducts: (json['orderProducts'] as List<dynamic>?)
              ?.map<OrderProductModel>(
                (e) => OrderProductModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      orderID: json['orderID']?.toString() ?? json['orderId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'uId': uId,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'status': status ?? 'pending',
      'totalPrice': totalPrice,
      'shippingAddressModel': shippingAddressModel.toJson(),
      'orderProducts': orderProducts.map((e) => e.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'orderID': orderID,
      'prescriptionImage': prescriptionImage,
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      totalPrice: totalPrice,
      uId: uId,
      orderID: orderID,
      prescriptionImage: prescriptionImage,
      shippingAddressModel: shippingAddressModel,
      orderProducts: orderProducts.map((e) => e.toEntity()).toList(),
      paymentMethod: paymentMethod,
      status: fetchEnum(),
      cancelledBy: cancelledBy,
      pharmacyId: pharmacyId, // تم التأكد من تمريره هنا
      pharmacyName: pharmacyName, // تم التأكد من تمريره هنا
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      orderID: entity.orderID,
      totalPrice: entity.totalPrice,
      uId: entity.uId,
      pharmacyId: entity.pharmacyId ?? '',
      pharmacyName: entity.pharmacyName ?? '',
      prescriptionImage: entity.prescriptionImage,
      cancelledBy: entity.cancelledBy,
      shippingAddressModel: entity.shippingAddressModel is ShippingAddressModel
          ? entity.shippingAddressModel as ShippingAddressModel
          : ShippingAddressModel(
              name: entity.shippingAddressModel.name,
              phone: entity.shippingAddressModel.phone,
              address: entity.shippingAddressModel.address,
              city: entity.shippingAddressModel.city,
              email: entity.shippingAddressModel.email,
              floor: entity.shippingAddressModel.floor,
            ),
      orderProducts: entity.orderProducts
          .map(
            (e) => OrderProductModel.fromEntity(e),
          )
          .toList(),
      paymentMethod: entity.paymentMethod,
      status: entity.status.name,
    );
  }

  OrderStatus fetchEnum() {
    return OrderStatus.values.firstWhere((e) {
      var enumStatus = e.name.toString();
      return enumStatus == (status ?? 'pending');
    }, orElse: () => OrderStatus.pending);
  }
}