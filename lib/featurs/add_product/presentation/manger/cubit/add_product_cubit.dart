// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/services/account_status_service.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/data/models/add_product_input_model.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/repos/inventory_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart' show kIsWeb; // استيراد معرف الويب
part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit(this.imagRepo, this.productRepo, this._inventoryRepo)
    : super(AddProductInitial());

  final ImagRepo imagRepo;
  final ProductRepo productRepo;
  final InventoryRepo _inventoryRepo;
  final AccountStatusService _accountStatusService = AccountStatusService();


  // 👈 1. ميثود جديدة لضغط الصورة (Image Compression Method)
Future<XFile?> _compressImage(XFile file) async {
  // 🛑 إذا كان التطبيق يعمل على الويب، نرجع الملف كما هو بدون ضغط
  // لأن الباكيج لا تدعم الويب حالياً في compressAndGetFile
  if (kIsWeb) {
    return file; 
  }

  try {
    final tempDir = await path_provider.getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );

    return result != null ? XFile(result.path) : null;
  } catch (e) {
    print("Compression Error: $e");
    return null;
  }
}

  Future<void> addProduct(
    AddProductIntety addProductIntety, {
    String? documentId,
  }) async {
    emit(AddProductLoading());

    Future<bool> canContinueWriting() async {
      try {
        await _accountStatusService.ensureAccountCanWrite(
          addProductIntety.pharmacyId!,
        );
        return true;
      } on AccountDisabledException catch (e) {
        await _accountStatusService.forceLogoutDisabledAccount();
        emit(AddProductAccountDisabled(message: e.message));
        return false;
      }
    }

    if (!await canContinueWriting()) return;

// 🛑 3. خطوة الضغط الجديدة: قبل الرفع
    XFile imageToUpload = addProductIntety.image;
    emit(AddProductError(error: "جاري ضغط الصورة...")); // اختياري لتحديث الـ UI

    final compressedXFile = await _compressImage(addProductIntety.image);
    if (compressedXFile != null) {
      imageToUpload = compressedXFile; // نستخدم الملف المضغوط للرفع
    }
    // ملاحظة: لو الضغط فشل لأي سبب، هنرفع الملف الأصلي زي ما هو كخطة بديلة.
    // 1️⃣ رفع الصورة
    final uploadResult = await imagRepo.uploadImage(imageToUpload);

    await uploadResult.fold(
      (failure) async => emit(AddProductError(error: failure.message)),
      (imageUrl) async {
        addProductIntety.imageurl = imageUrl;

        try {
          if (!await canContinueWriting()) return;

          final firestore = FirebaseFirestore.instance;
          // تأكيد الـ ID الموحد: (باركود المنتج _ معرف الصيدلية)
          final String finalDocId =
              documentId ??
              "${addProductIntety.code}_${addProductIntety.pharmacyId}";

          // 2️⃣ استخدام Write Batch لضمان الإضافة في "المنتجات" و "المخزن" معاً
          final batch = firestore.batch();

          // مرجع المنتج في collection المنتجات
          final productRef = firestore.collection('products').doc(finalDocId);

          // مرجع المخزن (نفس الـ ID لسهولة الوصول والجرد)
          // تأكد من اسم الـ collection عندك، لو 'inventory' أو 'stock'
          final inventoryRef = firestore
              .collection('inventory')
              .doc(finalDocId);

          // تجهيز بيانات المنتج
          final productModel = AddProductInputModel.fromentity(
            addProductIntety,
          );
          final productJson = productModel.toJson();
          productJson['pharmacyId'] = addProductIntety.pharmacyId;
          productJson['isPrescriptionRequired'] =
              addProductIntety.isPrescriptionRequired;
          productJson['pharmacyName'] =
              addProductIntety.pharmacyName; // جلبناه من الـ doc
          productJson['pharmacyLat'] =
              addProductIntety.pharmacyLat; // جلبناه من الـ doc
          productJson['pharmacyLng'] = addProductIntety.pharmacyLng;
          // إضافة/تحديث المنتج في الـ Batch
          batch.set(productRef, productJson, SetOptions(merge: true));

          // تجهيز بيانات المخزن (Inventory)
          final expiryDateTime = addProductIntety.expirationDate;

          batch.set(inventoryRef, {
            'productId': finalDocId,
            'productName': addProductIntety.name,
            'quantity': FieldValue.increment(
              addProductIntety.unitAmount ?? 0,
            ), // زيادة المخزن لو المنتج موجود
            'pharmacyId': addProductIntety.pharmacyId,
            'category': addProductIntety.category,

            'expiryDate': Timestamp.fromDate(expiryDateTime),
            'costPrice': addProductIntety.cost,
            'sellingPrice': addProductIntety.price,
            'productImageUrl': imageUrl,
            'code': addProductIntety.code,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // 3️⃣ تنفيذ العملية "الذرية" (Atomic)
          await batch.commit();

          emit(AddProductSuccess());
        } catch (e) {
          emit(AddProductError(error: "خطأ في مزامنة المخزن: ${e.toString()}"));
        }
      },
    );
  }


  // DateTime _convertIntToDateTime(int dateInt) {
  //   try {
  //     String dateStr = dateInt.toString();
  //     if (dateStr.length < 8) return DateTime.now().add(const Duration(days: 365));

  //     int year = int.parse(dateStr.substring(0, 4));
  //     int month = int.parse(dateStr.substring(4, 6));
  //     int day = int.parse(dateStr.substring(6, 8));
  //     return DateTime(year, month, day);
  //   } catch (e) {
  //     return DateTime.now().add(const Duration(days: 365));
  //   }
  // }
}
