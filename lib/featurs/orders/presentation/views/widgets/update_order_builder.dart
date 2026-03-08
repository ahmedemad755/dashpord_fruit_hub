import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/build_error_bar.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/manger/fetch_ordres/fetch_orders_cubit.dart'; // تأكد من استيراد الـ Cubit
import 'package:fruitesdashboard/featurs/orders/presentation/manger/update_order/update_order_cubit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UpdateOrderBuilder extends StatelessWidget {
  const UpdateOrderBuilder({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateOrderCubit, UpdateOrderState>(
      listener: (context, state) {
        if (state is UpdateOrderSuccess) {
          // 1. إظهار رسالة النجاح
          buildBar(
            context,
            'تم تحديث حالة الطلب بنجاح ✅',
            backgroundColor: Colors.teal,
          );

          // 2. تحديث القائمة فوراً (هنا الإضافة)
          // نقوم بطلب البيانات الجديدة لتظهر الحالة المحدثة (شحن/توصيل) تلقائياً
          context.read<FetchOrdersCubit>().fetchOrders();
        }

        if (state is UpdateOrderFailure) {
          buildBar(
            context,
            state.errMessage,
            backgroundColor: Colors.redAccent,
          );
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is UpdateOrderLoading,
          opacity: 0.2,
          progressIndicator: const CircularProgressIndicator(
            color: Colors.teal,
          ),
          child: child,
        );
      },
    );
  }
}
