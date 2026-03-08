import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/add_product_view_body_blocbuilder.dart';

class AddProductView extends StatelessWidget {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddProductCubit>(),
      child: const AddProductViewBodyBlocbuilder(),
    );
  }
}
