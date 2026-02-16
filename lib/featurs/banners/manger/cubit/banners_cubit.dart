import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:fruitesdashboard/featurs/data/entity/BannerEntity.dart';
import 'package:fruitesdashboard/featurs/data/repos/banners_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  BannersCubit(this.bannersRepo) : super(BannersInitial());

  final BannersRepo bannersRepo;
  File? selectedImage;

  // 1. اختيار صورة من الاستوديو
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      emit(BannerImageSelected(selectedImage!));
    }
  }

  // 2. جلب كل العروض
  Future<void> getBanners() async {
    emit(GetBannersLoading());
    final result = await bannersRepo.getBanners();

    result.fold(
      (failure) => emit(GetBannersFailure(failure.message)),
      (banners) => emit(GetBannersSuccess(banners)),
    );
  }

  // 3. إضافة عرض جديد
  Future<void> addBanner({
    required String linkType,
    String? targetId,
    required bool isActive,
  }) async {
    if (selectedImage == null) {
      emit(AddBannerFailure('يرجى اختيار صورة أولاً'));
      return;
    }

    emit(AddBannerLoading());

    // ننشئ Entity مؤقت لإرساله للـ Repo
    final banner = BannerEntity(
      id: '', // الـ Repo سيتعامل مع الـ ID
      imageUrl: '', // سيتم تحديثه برابط الرفع في الـ Repo
      linkType: linkType,
      targetId: targetId,
      isActive: isActive,
      createdAt: DateTime.now(),
    );

    final result = await bannersRepo.addBanner(banner, selectedImage!);

    result.fold((failure) => emit(AddBannerFailure(failure.message)), (
      success,
    ) {
      selectedImage = null; // تفريغ الصورة بعد النجاح
      emit(AddBannerSuccess());
      getBanners(); // تحديث القائمة تلقائياً بعد الإضافة
    });
  }

  // 4. حذف عرض
  Future<void> deleteBanner(BannerEntity banner) async {
    final result = await bannersRepo.deleteBanner(banner);
    result.fold(
      (failure) => emit(GetBannersFailure(failure.message)),
      (success) => getBanners(), // تحديث القائمة بعد الحذف
    );
  }
}
