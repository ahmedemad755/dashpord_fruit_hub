import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/custom_button.dart';

class DashBoardBody extends StatelessWidget {
  const DashBoardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addProduct);
            },
            label: "Add Data",
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.orders);
            },
            label: "view Orders",
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.DashboardAnalytics);
            },
            label: "DashboardAnalytics",
          ),
        ],
      ),
    );
  }
}
