import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/function_helper/build_error_bar.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/add_product_body.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/customProgressLoading.dart';

class AddProductViewBodyBlocbuilder extends StatelessWidget {
  const AddProductViewBodyBlocbuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      listener: (context, state) {
        if (state is AddProductSuccess) {
          buildBar(
            context,
            "تم إضافة المنتج بنجاح",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.green,
          );
          Navigator.pop(context); // العودة للخلف بعد النجاح
        } else if (state is AddProductError) {
          buildBar(context, state.error, backgroundColor: Colors.red);
        }
      },
      builder: (context, state) {
        return CustomProgresIndecatorHUD(
          isLoading: state is AddProductLoading,
          child: AddProductBody(),
        );
      },
    );
  }
}
