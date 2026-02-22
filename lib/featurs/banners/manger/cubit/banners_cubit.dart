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

    final banner = BannerEntity(
      id: '',
      imageUrl: '',
      linkType: linkType,
      targetId: targetId,
      isActive: isActive,
      createdAt: DateTime.now(),
    );

    final result = await bannersRepo.addBanner(banner, selectedImage!);

    result.fold((failure) => emit(AddBannerFailure(failure.message)), (
      success,
    ) {
      selectedImage = null;
      emit(AddBannerSuccess());
      getBanners();
    });
  }

  // 4. حذف عرض (تم الإصلاح هنا ليتوافق مع الـ Repo)
  Future<void> deleteBanner(BannerEntity banner) async {
    // حفظ الحالة السابقة لاستعادتها عند الفشل
    final currentState = state;
    List<BannerEntity> oldBanners = [];
    if (currentState is GetBannersSuccess) {
      oldBanners = currentState.banners;
    }

    emit(GetBannersLoading());

    // نمرر الـ banner كاملاً (وليس banner.id) ليتوافق مع تعريف الـ Repo
    var result = await bannersRepo.deleteBanner(banner);

    result.fold(
      (failure) {
        emit(GetBannersFailure(failure.message));
        // استعادة القائمة القديمة لضمان عدم توقف الواجهة
        if (oldBanners.isNotEmpty) {
          emit(GetBannersSuccess(oldBanners));
        }
      },
      (success) {
        getBanners(); // تحديث البيانات بعد الحذف بنجاح
      },
    );
  }
}
