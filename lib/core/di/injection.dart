import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo_imp.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo_imp.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/firebase_auth_service.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:fruitesdashboard/core/services/supabase_storge.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo.dart';
import 'package:fruitesdashboard/featurs/auth/data/repos/pharmacy_repo/pharmacy_auth_repo_impl.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/login/pharmacy_login_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/signup/pharmacy_signup_cubit.dart';
import 'package:fruitesdashboard/featurs/auth/presentation/cubits/vereficationotp/vereficationotp_cubit.dart';
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
  // 2️⃣ Repositories (Pharmacy Auth)
  // ---------------------------
  getIt.registerSingleton<PharmacyAuthRepo>(
    PharmacyAuthRepoImpl(
      firebaseAuthService: getIt<FirebaseAuthService>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  // ---------------------------
  // 3️⃣ Other Repositories
  // ---------------------------
  getIt.registerFactory<ProductRepo>(
    () => ProductRepoImp(fireStoreService: getIt.get<FireStoreService>()),
  );

  getIt.registerSingleton<ImagRepo>(ImagRepoImp(getIt.get<StorgeService>()));

  getIt.registerSingleton<OrdersRepo>(
    OrdersRepoImpl(getIt.get<DatabaseService>()),
  );

  getIt.registerLazySingleton<BannersRepo>(
    () => BannersRepoImpl(
      databaseService: getIt.get<DatabaseService>(),
      storgeService: getIt.get<StorgeService>(),
    ),
  );

  // ---------------------------
  // 4️⃣ Cubits
  // ---------------------------

  getIt.registerFactory<PharmacySignupCubit>(
    () => PharmacySignupCubit(getIt<PharmacyAuthRepo>()),
  );

  // ✅ تم التعديل هنا من Singleton إلى Factory لحل مشكلة "Cannot emit after close"
  getIt.registerFactory<PharmacyLoginCubit>(
    () => PharmacyLoginCubit(getIt<PharmacyAuthRepo>()),
  );

  getIt.registerFactory<OTPCubit>(() => OTPCubit(getIt<PharmacyAuthRepo>()));

  getIt.registerFactory<BannersCubit>(() => BannersCubit(getIt<BannersRepo>()));
}
