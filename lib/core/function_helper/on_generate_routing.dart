import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/core/function_helper/widgets/DashboardAnalytics.dart';
import 'package:fruitesdashboard/core/widgets/account_status_guard.dart';
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
import 'package:fruitesdashboard/featurs/dashboard/presentation/views/dashboard_view.dart';
import 'package:fruitesdashboard/featurs/dashboard/presentation/widgets/ProductsCategoryView.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/views/inventory_view.dart';
import 'package:fruitesdashboard/featurs/offers/presentation/cubit/offers_cubit.dart';
import 'package:fruitesdashboard/featurs/offers/presentation/views/offers_view.dart';
import 'package:fruitesdashboard/featurs/orders/presentation/views/orders_view.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_cubit.dart';
import 'package:fruitesdashboard/maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:fruitesdashboard/maps/data/repo/place_repo.dart';
import 'package:fruitesdashboard/maps/data/web/place_web_servises.dart';
import 'package:fruitesdashboard/maps/presentation/screens/map_screen.dart';

class AppRoutes {
  static const String dashboard = 'dashboard';
  static const String addProduct = 'addProduct';
  static const String orders = 'orders';
  static const String DashboardAnalytics = 'DashboardAnalytics';
  static const String productsCategory = 'productsCategory';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String forgotPassword = 'forgotPassword';
  static const String otp = 'otp';
  static const String sendResetPassword = 'sendResetPassword';
  static const String pendingApproval = 'pendingApproval';
  static const String inventory = 'inventory';
  static const String offersManagement = 'offersManagement';
  static const String mapScreen = 'mapScreen';
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
            BlocProvider(create: (context) => getIt<SensorCubit>()..monitorSensor()),
          ],
          child: const AccountStatusGuard(child: DashBoardView()),
        ),
      );

            case AppRoutes.mapScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (BuildContext context) =>
                MapsCubit(MapsRepository(PlacesWebservices())),
            child: MapScreen(),
          ),
        );

    case AppRoutes.addProduct:
      return MaterialPageRoute(
        builder: (context) => const AccountStatusGuard(child: AddProductView()),
      );

    case AppRoutes.orders:
      return MaterialPageRoute(
        builder: (context) => AccountStatusGuard(child: OrdersView()),
      );

    case AppRoutes.DashboardAnalytics:
      return MaterialPageRoute(builder: (context) => DashboardAnalyticsView());

    case AppRoutes.productsCategory:
      return MaterialPageRoute(
        builder: (context) =>
            const AccountStatusGuard(child: ProductsCategoryView()),
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
    final String currentPharmacyId = FirebaseAuth.instance.currentUser?.uid ?? "";
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<InventoryCubit>()..getInventory(currentPharmacyId),
          child: const AccountStatusGuard(child: InventoryView()),
        ),
      );
case AppRoutes.offersManagement:
  final String currentPharmacyId = FirebaseAuth.instance.currentUser?.uid ?? "";
  return MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => getIt<OffersCubit>()..fetchOffers(currentPharmacyId),
      child: const AccountStatusGuard(child: OffersView()),
    ),
  );
    default:
      return MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<PharmacyLoginCubit>()),
            BlocProvider.value(value: getIt<RoleCubit>()),
          ],
          child: const AccountStatusGuard(child: DashBoardView()),
        ),
      );
  }
}
