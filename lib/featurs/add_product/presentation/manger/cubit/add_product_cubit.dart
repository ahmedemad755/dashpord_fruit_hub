// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit(this.imagRepo, this.productRepo) : super(AddProductInitial());

  final ImagRepo imagRepo;
  final ProductRepo productRepo;

  Future<void> addProduct(AddProductIntety addProductIntety) async {
    emit(AddProductLoading());

    // 1️⃣ ارفع الصورة
    final uploadResult = await imagRepo.uploadImage(addProductIntety.image);

    uploadResult.fold(
      (failure) {
        emit(AddProductError(error: failure.message));
      },
      (imageUrl) async {
        // 2️⃣ حدّث الـ entity باللينك الجديد
        addProductIntety.imageurl = imageUrl;

        // 3️⃣ خزّن المنتج في Firestore
        final productResult = await productRepo.addProduct(addProductIntety);

        productResult.fold(
          (failure) {
            emit(AddProductError(error: failure.message));
          },
          (_) {
            emit(AddProductSuccess());
          },
        );
      },
    );
  }
}
