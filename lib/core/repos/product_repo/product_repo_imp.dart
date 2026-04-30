import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/data/models/add_product_input_model.dart';

class ProductRepoImp implements ProductRepo {
  final FireStoreService fireStoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProductRepoImp({required this.fireStoreService});

  @override
  Future<Either<Faliur, String>> addProduct(
    AddProductIntety addProductIntety, {
    String? documentId,
  }) async {
    try {
      final String? currentPharmacyId = _auth.currentUser?.uid;

      if (currentPharmacyId == null) {
        return left(ServerFaliur("❌ يجب تسجيل الدخول أولاً"));
      }

      // 1. تحويل الـ Entity إلى Model لاستخدام toJson
      final productModel = AddProductInputModel.fromentity(addProductIntety);
      final Map<String, dynamic> productJson = productModel.toJson();

      // 2. إضافة الحقول الإضافية الهامة قبل الإرسال لـ Firestore
      productJson['pharmacyId'] = currentPharmacyId;
      productJson['pharmacyName'] = addProductIntety.pharmacyName;
      productJson['pharmacyLat'] = addProductIntety.pharmacyLat;
      productJson['pharmacyLng'] = addProductIntety.pharmacyLng;
      productJson['isPrescriptionRequired'] = addProductIntety.isPrescriptionRequired;

      // تحديد المعرف الفريد للمنتج (الباركود + كود الصيدلية) لضمان عدم التكرار
      final String finalDocId =
          documentId ?? "${addProductIntety.code}_$currentPharmacyId";

      await fireStoreService.addData(
        path: BackendPoints.addProduct,
        data: productJson,
        documentId: finalDocId,
      );

      // 🔥 الإصلاح: إرجاع الـ ID الحقيقي بدلاً من جملة النجاح النصية
      // لكي يتمكن الـ Cubit من استخدامه لربط المنتج بمجموعة الـ inventory
      return right(finalDocId); 
      
    } catch (e, stack) {
      log(
        "❌ Firestore Add Error: $e",
        name: "ProductRepoImp",
        error: e,
        stackTrace: stack,
      );
      return left(ServerFaliur("❌ فشل في إضافة المنتج: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Faliur, List<AddProductIntety>>> getProducts() async {
    try {
      final String? currentPharmacyId = _auth.currentUser?.uid;

      if (currentPharmacyId == null) {
        return left(ServerFaliur("❌ غير مسموح بالوصول - يجب تسجيل الدخول"));
      }

      final result = await fireStoreService.getData(
        path: BackendPoints.addProduct,
        query: {'field': 'pharmacyId', 'value': currentPharmacyId},
      );

      final List<dynamic> data = result as List<dynamic>;
      
      // تحويل البيانات من List<Map> إلى List<Entity>
      List<AddProductIntety> products = data.map((e) {
        return AddProductInputModel.fromJson(e as Map<String, dynamic>).toEntity();
      }).toList();

      return right(products);
    } catch (e) {
      log("❌ Fetch Products Error: $e", name: "ProductRepoImp");
      return left(ServerFaliur("❌ فشل جلب المنتجات: ${e.toString()}"));
    }
  }
}