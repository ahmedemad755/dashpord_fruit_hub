part of 'add_product_cubit.dart';

@immutable
sealed class AddProductState {}

final class AddProductInitial extends AddProductState {}

final class AddProductLoading extends AddProductState {}

final class AddProductSuccess extends AddProductState {}

final class AddProductError extends AddProductState {
  final String error;
  AddProductError({required this.error});
}

final class AddProductAccountDisabled extends AddProductState {
  final String message;
  AddProductAccountDisabled({
    this.message = '403 Forbidden: تم تعطيل حسابك، يرجى التواصل مع الإدارة',
  });
}
