import 'package:flutter/material.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/views/add_product_view.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/views/dashboard_view.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/orders_view.dart';

class AppRoutes {
  static const String dashboard = 'dashboard';
  static const String addProduct = 'addProduct';
  static const String orders = 'orders';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.dashboard:
      return MaterialPageRoute(builder: (context) => DashboardView());
    case AppRoutes.addProduct:
      return MaterialPageRoute(builder: (context) => AddProductView());
    case AppRoutes.orders:
      return MaterialPageRoute(builder: (context) => OrdersView());
    default:
      return MaterialPageRoute(builder: (context) => DashboardView());
  }
}
