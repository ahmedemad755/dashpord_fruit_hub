part of 'update_order_cubit.dart';

@immutable
sealed class UpdateOrderState {}

final class UpdateOrderInitial extends UpdateOrderState {}

final class UpdateOrderLoading extends UpdateOrderState {}

final class UpdateOrderFailure extends UpdateOrderState {
  final String errMessage;

  UpdateOrderFailure(this.errMessage);
}

final class UpdateOrderSuccess extends UpdateOrderState {}

// الحالة الخاصة بالتحديث اللحظي لقائمة الأدوية والسعر
final class UpdateOrderProductsChanged extends UpdateOrderState {
  final List<OrderProductEntity> tempProducts;
  final double totalPrice;
  final DateTime timeStamp; // لضمان إعادة بناء الواجهة عند كل تغيير

  UpdateOrderProductsChanged({
    required this.tempProducts,
    required this.totalPrice,
    required this.timeStamp,
  });
}