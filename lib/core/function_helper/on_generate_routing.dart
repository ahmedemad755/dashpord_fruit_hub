import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/DashboardAnalytics.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/views/add_product_view.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/roles/role_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/signup/pharmacy_signup_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/view/PendingApprovalView.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/view/Pharmacy_Signup_Screen.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/view/forgot_password_view.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/view/login_view.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/view/oTPVerificationScreen.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/view/reset_Password.dart';
import 'package:fruitesdashboard/featurs/banners/manger/cubit/banners_cubit.dart';
import 'package:fruitesdashboard/featurs/banners/presentation/views/BannersManagementView.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/views/dashboard_view.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/ProductsCategoryView.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/views/inventory_view.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/orders_view.dart';

class AppRoutes {
  static const String dashboard = 'dashboard';
  static const String addProduct = 'addProduct';
  static const String orders = 'orders';
  static const String DashboardAnalytics = 'DashboardAnalytics';
  static const String productsCategory = 'productsCategory';
  static const String bannersManagement = 'bannersManagement';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String forgotPassword = 'forgotPassword';
  static const String otp = 'otp';
  static const String sendResetPassword = 'sendResetPassword';
  static const String pendingApproval = 'pendingApproval';
  static const String inventory = 'inventory';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.dashboard:
    case AppRoutes.home:
      return MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<PharmacyLoginCubit>()),
            BlocProvider.value(value: getIt<RoleCubit>()),
          ],
          child: const DashBoardView(),
        ),
      );

    case AppRoutes.addProduct:
      return MaterialPageRoute(builder: (context) => AddProductView());

    case AppRoutes.orders:
      return MaterialPageRoute(builder: (context) => OrdersView());

    case AppRoutes.DashboardAnalytics:
      return MaterialPageRoute(builder: (context) => DashboardAnalyticsView());

    case AppRoutes.productsCategory:
      return MaterialPageRoute(
        builder: (context) => const ProductsCategoryView(),
      );

    case AppRoutes.bannersManagement:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt.get<BannersCubit>()..getBanners(),
          child: const BannersManagementView(),
        ),
      );

    case AppRoutes.login:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<PharmacyLoginCubit>(),
          child: const LoginView(),
        ),
      );

    case AppRoutes.signup:
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: getIt<PharmacySignupCubit>(),
          child: const PharmacySignupView(),
        ),
      );

    case AppRoutes.forgotPassword:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => getIt<OTPCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      );

    case AppRoutes.otp:
      final args = settings.arguments as Map<String, dynamic>;
      final otpCubit = args['cubit'] as OTPCubit;
      final phoneNumber = args['phone'] as String?;
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: otpCubit,
          child: OTPVerificationScreen(phoneNumber: phoneNumber),
        ),
      );

    case AppRoutes.sendResetPassword:
      return MaterialPageRoute(builder: (_) => const SendResetPassword());

    case AppRoutes.pendingApproval:
      return MaterialPageRoute(builder: (_) => const PendingApprovalView());

    case AppRoutes.inventory:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<InventoryCubit>()..getInventory(),
          child: const InventoryView(),
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<PharmacyLoginCubit>()),
            BlocProvider.value(value: getIt<RoleCubit>()),
          ],
          child: const DashBoardView(),
        ),
      );
  }
}
