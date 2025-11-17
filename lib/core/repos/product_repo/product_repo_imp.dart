import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/data/models/add_product_input_model.dart';

class ProductRepoImp implements ProductRepo {
  final FireStoreService fireStoreService;

  ProductRepoImp({required this.fireStoreService});

  @override
  Future<Either<Faliur, String>> addProduct(
    AddProductIntety addProductIntety,
  ) async {
    try {
      await fireStoreService.firestore
          .collection("products") // 👈 اسم الكولكشن في Firestore
          .doc(addProductIntety.code) // 👈 الـ documentId = كود المنتج
          .set(AddProductInputModel.fromentity(addProductIntety).toJson());

      return right("✅ Product added successfully to Firestore");
    } catch (e, stack) {
      // اطبع الرسالة كاملة في اللوج
      log(
        "❌ Firestore Add Error: $e",
        name: "ProductRepoImp",
        error: e,
        stackTrace: stack,
      );
      return left(ServerFaliur("❌ Failed to add product: ${e.toString()}"));
    }
  }
}
