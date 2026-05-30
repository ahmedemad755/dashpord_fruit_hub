import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 إضافة استيراد الـ Firestore إن لم يكن موجوداً
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo_imp.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo_imp.dart';
import 'package:fruitesdashboard/core/services/account_status_service.dart'; // 💡 استيراد خدمة حالة الحساب
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/firebase_auth_service.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:fruitesdashboard/core/services/supabase_storge.dart';
import 'package:fruitesdashboard/featurs/add_product/presentation/manger/cubit/add_product_cubit.dart'; 
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo_impl.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/roles/role_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/signup/pharmacy_signup_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_cubit.dart';
import 'package:fruitesdashboard/featurs/dashboard/data/services/global_product_matching_service.dart';
import 'package:fruitesdashboard/featurs/inventory/data/repos/inventory_repo_impl.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/repos/inventory_repo.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:fruitesdashboard/featurs/offers/data/repos/offers_repo_impl.dart';
import 'package:fruitesdashboard/featurs/offers/domain/repos/offers_repo.dart';
import 'package:fruitesdashboard/featurs/offers/presentation/cubit/offers_cubit.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:fruitesdashboard/featurs/orders/data/repos/orders_repo_impl.dart';
import 'package:fruitesdashboard/featurs/sensors/data/repos/sensor_repo_imp.dart';
import 'package:fruitesdashboard/featurs/sensors/domain/repos/Sensor_repository.dart';
import 'package:fruitesdashboard/featurs/sensors/presentation/cubits/cubit/sensor_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // ---------------------------
  // 1️⃣ Core Infrastructure Services
  // ---------------------------
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerSingleton<StorgeService>(SupabaseStorgeService());
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());

  final fireStoreService = FireStoreService();
  getIt.registerSingleton<FireStoreService>(fireStoreService);
  getIt.registerSingleton<DatabaseService>(fireStoreService);

  // ---------------------------
  // 2️⃣ App Business Services
  // ---------------------------
  // تسجيل خدمة التحقق من حالة الحساب لضمان توفرها عالمياً
  getIt.registerLazySingleton<AccountStatusService>(() => AccountStatusService());

  // ✅ تسجيل خدمة الرفع الجماعي والمطابقة مع تمرير الاعتمادات المطلوبة من الـ getIt
  getIt.registerLazySingleton<GlobalProductMatchingService>(
    () => GlobalProductMatchingService(
      firestore: FirebaseFirestore.instance,
      imageRepo: getIt<ImagRepo>(),
      accountStatusService: getIt<AccountStatusService>(),
    ),
  );

  // ---------------------------
  // 3️⃣ Repositories (Pharmacy Auth)
  // ---------------------------
  getIt.registerSingleton<PharmacyAuthRepo>(
    PharmacyAuthRepoImpl(
      firebaseAuthService: getIt<FirebaseAuthService>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  // ---------------------------
  // 4️⃣ Other Repositories
  // ---------------------------
  getIt.registerFactory<ProductRepo>(
    () => ProductRepoImp(fireStoreService: getIt.get<FireStoreService>()),
  );

  getIt.registerSingleton<ImagRepo>(ImagRepoImp(getIt.get<StorgeService>()));

  getIt.registerFactory<OrdersRepo>(
    () => OrdersRepoImpl(getIt.get<DatabaseService>()),
  );

  // تسجيل Repository للمخزون
  getIt.registerLazySingleton<InventoryRepo>(
    () => InventoryRepoImpl(getIt<DatabaseService>()),
  );

  // ---------------------------
  // 5️⃣ Cubits
  // ---------------------------
  getIt.registerFactory<PharmacySignupCubit>(
    () => PharmacySignupCubit(getIt<PharmacyAuthRepo>()),
  );

  // تفادي مشكلة "Cannot emit after close" عن طريق الـ Factory
  getIt.registerFactory<PharmacyLoginCubit>(
    () => PharmacyLoginCubit(getIt<PharmacyAuthRepo>()),
  );

  getIt.registerFactory<OTPCubit>(() => OTPCubit(getIt<PharmacyAuthRepo>()));

  // تسجيل Cubit للمخزون
  getIt.registerFactory<InventoryCubit>(
    () => InventoryCubit(getIt<InventoryRepo>()),
  );

  // تسجيل الـ Cubit الخاص بإضافة المنتج مع الـ Repository الخاص بالمخزون
  getIt.registerFactory<AddProductCubit>(
    () => AddProductCubit(
      getIt<ImagRepo>(),
      getIt<ProductRepo>(),
      getIt<InventoryRepo>(), 
    ),
  );

  getIt.registerLazySingleton<RoleCubit>(() => RoleCubit());

  // ---------------------------
  // Offers Cubit and Repo
  // ---------------------------
  getIt.registerLazySingleton<OffersRepo>(
    () => OffersRepoImpl(), 
  );

  getIt.registerFactory<OffersCubit>(
    () => OffersCubit(getIt<OffersRepo>()),
  );

  // ---------------------------
  // Sensors Cubit and Repo
  // ---------------------------
  getIt.registerLazySingleton<SensorRepository>(
    () => SensorRepositoryImpl(),
  );

  getIt.registerFactory<SensorCubit>(
    () => SensorCubit(getIt<SensorRepository>()),
  );
}