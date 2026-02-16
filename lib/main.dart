import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/const/const.dart';
import 'package:fruitesdashboard/core/di/injection.dart';
import 'package:fruitesdashboard/core/function_helper/on_generate_routing.dart';
import 'package:fruitesdashboard/core/services/custom_bloc_observer.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart'; // ✅ أضف هذا المسار
import 'package:fruitesdashboard/core/services/supabase_storge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ تأكد من تهيئة Shared Preferences أولاً لأن التطبيق يعتمد عليه في التحقق من الدخول
  await Prefs.init();

  // 2️⃣ تهيئة Firebase
  await Firebase.initializeApp();

  // 3️⃣ تهيئة Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // تأكد من وجود البوكيت (Bucket) لرفع صور الأدوية
  final storageService = SupabaseStorgeService();
  await storageService.ensureBucketExists(supabaseBucketName);

  // 4️⃣ إعداد حقن الاعتماديات (Dependency Injection)
  setupGetIt();

  // 5️⃣ مراقب الـ Bloc
  Bloc.observer = CustomBlocObserver();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صيدليتي - داشبورد',
      debugShowCheckedModeBanner: false,

      // ✅ دعم اللغة العربية واتجاه النص من اليمين لليسار
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      // ✅ تحديد المسار الابتدائي بناءً على حالة تسجيل الدخول
      initialRoute: Prefs.getBool("isLoggedIn") == true
          ? AppRoutes.home
          : AppRoutes.login,

      onGenerateRoute: onGenerateRoute,
    );
  }
}
