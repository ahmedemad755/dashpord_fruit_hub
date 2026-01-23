import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/const/const.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/services/custom_bloc_observer.dart';
import 'package:fruitesdashboard/core/services/supabase_storge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ init supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  // 2️⃣ تأكد من وجود البوكيت
  final storageService = SupabaseStorgeService();
  await storageService.ensureBucketExists(supabaseBucketName);
  // ✅ init firebase
  await Firebase.initializeApp();
  // ✅ setup dependency injection
  setupGetIt();

  Bloc.observer = CustomBlocObserver();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.dashboard,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
