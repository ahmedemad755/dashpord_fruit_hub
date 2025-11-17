import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/core/function_helper/get_order_dummy_data.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/manger/fetch_ordres/fetch_orders_cubit.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/manger/update_order/update_order_cubit.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/orders_view_body.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/widgets/update_order_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FetchOrdersCubit(getIt.get<OrdersRepo>()),
        ),
        BlocProvider(
          create: (context) => UpdateOrderCubit(getIt.get<OrdersRepo>()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Center(child: const Text('Orders'))),
        body: UpdateOrderBuilder(child: OrdersViewBodyBUilder()),
      ),
    );
  }
}

class OrdersViewBodyBUilder extends StatefulWidget {
  const OrdersViewBodyBUilder({super.key});

  @override
  State<OrdersViewBodyBUilder> createState() => _OrdersViewBodyBUilderState();
}

class _OrdersViewBodyBUilderState extends State<OrdersViewBodyBUilder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchOrdersCubit>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchOrdersCubit, FetchOrdersState>(
      builder: (context, state) {
        if (state is FetchOrdersLoading) {
          return Skeletonizer(
            child: OrdersViewBody(orders: [getDummyOrder(), getDummyOrder()]),
          );
        } else if (state is FetchOrdersSuccess) {
          return OrdersViewBody(orders: state.orders);
        } else if (state is FetchOrdersFailure) {
          return Center(child: Text(state.errMessage));
        } else {
          return Skeletonizer(
            child: OrdersViewBody(orders: [getDummyOrder(), getDummyOrder()]),
          );
        }
      },
    );
  }
}
