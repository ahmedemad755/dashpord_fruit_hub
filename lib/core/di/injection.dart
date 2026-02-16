import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo_imp.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo_imp.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/firebase_auth_service.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:fruitesdashboard/core/services/supabase_storge.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/auth_repo_impl.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/signup/sugnup_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_cubit.dart'; // ✅ أضف هذا المسار لـ OTP
import 'package:fruitesdashboard/featurs/banners/manger/cubit/banners_cubit.dart';
import 'package:fruitesdashboard/featurs/data/repos/banners_repo.dart';
import 'package:fruitesdashboard/featurs/data/repos/banners_repo_impl.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:fruitesdashboard/featurs/orders/data/repos/orders_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // ---------------------------
  // 1️⃣ Services
  // ---------------------------
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerSingleton<StorgeService>(SupabaseStorgeService());
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());

  final fireStoreService = FireStoreService();
  getIt.registerSingleton<FireStoreService>(fireStoreService);
  getIt.registerSingleton<DatabaseService>(fireStoreService);

  // ---------------------------
  // 2️⃣ Repositories (Auth & Others)
  // ---------------------------

  // تسجيل الـ AuthRepo الأساسي
  getIt.registerSingleton<AuthRepo>(
    AuthRepoImpl(
      firebaseAuthService: getIt<FirebaseAuthService>(),
      databaseservice: getIt<DatabaseService>(),
      fireStoreService: getIt<FireStoreService>(),
    ),
  );

  // ✅ إضافة الـ Casting اللي كنت بتستخدمه في تطبيق اليوزر لضمان التوافق
  getIt.registerSingleton<AuthRepoImpl>(getIt<AuthRepo>() as AuthRepoImpl);

  // Products Repository
  getIt.registerFactory<ProductRepo>(
    () => ProductRepoImp(fireStoreService: getIt.get<FireStoreService>()),
  );

  // Images Repository
  getIt.registerSingleton<ImagRepo>(ImagRepoImp(getIt.get<StorgeService>()));

  // Orders Repository
  getIt.registerSingleton<OrdersRepo>(
    OrdersRepoImpl(getIt.get<DatabaseService>()),
  );

  // Banners Repository
  getIt.registerLazySingleton<BannersRepo>(
    () => BannersRepoImpl(
      databaseService: getIt.get<DatabaseService>(),
      storgeService: getIt.get<StorgeService>(),
    ),
  );

  // ---------------------------
  // 3️⃣ Cubits
  // ---------------------------

  // ✅ تسجيل كل الـ Cubits الخاصة بالـ Auth كما في تطبيق اليوزر
  getIt.registerFactory<SugnupCubit>(() => SugnupCubit(getIt<AuthRepo>()));

  // جعلنا LoginCubit سينجلتون كما في كود اليوزر لضمان ثبات حالة الدخول
  getIt.registerSingleton<LoginCubit>(LoginCubit(getIt<AuthRepo>()));

  // ✅ حل مشكلة OTPCubit النهائية
  getIt.registerFactory<OTPCubit>(() => OTPCubit(getIt<AuthRepo>()));

  // Banners Cubit
  getIt.registerFactory<BannersCubit>(() => BannersCubit(getIt<BannersRepo>()));
}
