import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo_imp.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo_imp.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:fruitesdashboard/core/services/supabase_storge.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:fruitesdashboard/featurs/orders/data/repos/orders_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // ---------------------------
  // 1️⃣ Supabase Client & Storage
  // ---------------------------
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerSingleton<StorgeService>(SupabaseStorgeService());
  // getIt.registerSingleton<SupabaseDatabaseService>(
  //   SupabaseDatabaseService(getIt.get<SupabaseClient>()),
  // );

  // ---------------------------
  // 2️⃣ Firestore Service
  // ---------------------------
  getIt.registerLazySingleton<FireStoreService>(() => FireStoreService());
  getIt.registerSingleton<DatabaseService>(getIt.get<FireStoreService>());

  // ---------------------------
  // 3️⃣ Repositories
  // ---------------------------

  // Products (Firestore)
  getIt.registerFactory<ProductRepo>(
    () => ProductRepoImp(fireStoreService: getIt.get<FireStoreService>()),
  );

  // Images (Supabase Storage)
  getIt.registerSingleton<ImagRepo>(ImagRepoImp(getIt.get<StorgeService>()));

  // Orders (Firestore)
  getIt.registerSingleton<OrdersRepo>(
    OrdersRepoImpl(getIt.get<DatabaseService>()),
  );
}
