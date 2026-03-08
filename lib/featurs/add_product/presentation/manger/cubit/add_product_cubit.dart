// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/repos/inventory_repo.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit(this.imagRepo, this.productRepo, this._inventoryRepo)
      : super(AddProductInitial());

  final ImagRepo imagRepo;
  final ProductRepo productRepo;
  final InventoryRepo _inventoryRepo;

  Future<void> addProduct(
    AddProductIntety addProductIntety, {
    String? documentId,
  }) async {
    emit(AddProductLoading());

    // 1️⃣ رفع الصورة أولاً
    final uploadResult = await imagRepo.uploadImage(addProductIntety.image);

    await uploadResult.fold(
      (failure) async => emit(AddProductError(error: failure.message)),
      (imageUrl) async {
        addProductIntety.imageurl = imageUrl;

        try {
          final firestore = FirebaseFirestore.instance;
          String finalProductId = '';

          // البحث عن المنتج بالباركود
          QuerySnapshot productQuery = await firestore
              .collection('products')
              .where('barcode', isEqualTo: addProductIntety.code)
              .limit(1)
              .get();

          if (productQuery.docs.isEmpty) {
            // --- إنشاء منتج جديد ---
            final productResult = await productRepo.addProduct(
              addProductIntety,
              documentId: documentId,
            );

            // استخراج الـ ID أو التوقف في حال الفشل
            bool hasError = false;
            productResult.fold(
              (failure) {
                emit(AddProductError(error: failure.message));
                hasError = true;
              },
              (id) => finalProductId = id,
            );

            if (hasError || finalProductId.isEmpty) return;
          } else {
            // --- تحديث منتج موجود ---
            finalProductId = productQuery.docs.first.id;
            await firestore.collection('products').doc(finalProductId).update({
              'unitAmount': FieldValue.increment(addProductIntety.unitAmount ?? 0),
              'isPrescriptionRequired': addProductIntety.isPrescriptionRequired,
            });
          }

          // 2️⃣ إضافة الدفعة (Batch) للمخزن برابط الـ ID الصحيح
          final expiryDateTime = _convertIntToDateTime(addProductIntety.expirationDate ?? 0);

          final inventoryItem = InventoryEntity(
            id: '', // سيقوم الـ Repo بإنشاء ID تلقائي للمخزن
            productId: finalProductId, // الربط بالمنتج الحقيقي 🔥
            productName: addProductIntety.name,
            quantity: addProductIntety.unitAmount ?? 0,
            reorderLevel: 5,
            expiryDate: expiryDateTime,
            costPrice: addProductIntety.cost.toDouble(),
            sellingPrice: addProductIntety.price.toDouble(),
            productImageUrl: imageUrl,
            category: addProductIntety.category,
            stockIn: addProductIntety.unitAmount ?? 0,
            stockOut: 0,
            damaged: 0,
          );

          await _inventoryRepo.addOrUpdateInventory(inventoryItem);
          emit(AddProductSuccess());
          
        } catch (e) {
          emit(AddProductError(error: "خطأ غير متوقع: ${e.toString()}"));
        }
      },
    );
  }

  DateTime _convertIntToDateTime(int dateInt) {
    try {
      String dateStr = dateInt.toString();
      if (dateStr.length < 8) return DateTime.now().add(const Duration(days: 365));

      int year = int.parse(dateStr.substring(0, 4));
      int month = int.parse(dateStr.substring(4, 6));
      int day = int.parse(dateStr.substring(6, 8));
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now().add(const Duration(days: 365));
    }
  }
}