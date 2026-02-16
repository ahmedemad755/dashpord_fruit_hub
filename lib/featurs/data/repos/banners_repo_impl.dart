import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/data/entity/BannerEntity.dart';
import 'package:fruitesdashboard/featurs/data/models/BannerModel.dart';
import 'package:fruitesdashboard/featurs/data/repos/banners_repo.dart';

class BannersRepoImpl implements BannersRepo {
  final DatabaseService databaseService;
  final StorgeService storgeService;

  BannersRepoImpl({required this.databaseService, required this.storgeService});

  @override
  Future<Either<Faliur, void>> addBanner(
    BannerEntity banner,
    File image,
  ) async {
    try {
      // 1. رفع الصورة أولاً والحصول على الرابط
      String? imageUrl = await storgeService.uploadImage(
        image,
        BackendPoints.bannersImages,
      );

      if (imageUrl == null) {
        return Left(ServerFaliur('فشل في رفع الصورة، يرجى المحاولة لاحقاً'));
      }

      // 2. تحويل الـ Entity لـ Model وتحديث رابط الصورة والـ ID
      final bannerModel = BannerModel(
        id: '', // Firestore هيعمل ID تلقائي لو استخدمنا addData بطريقة معينة أو ننشئه هنا
        imageUrl: imageUrl,
        targetId: banner.targetId,
        linkType: banner.linkType,
        isActive: banner.isActive,
        createdAt: banner.createdAt,
      );

      // 3. حفظ البيانات في Firestore
      // ملحوظة: لو عاوز تستخدم الـ ID بتاع Firestore كـ Document ID:
      await databaseService.addData(
        path: BackendPoints.banners,
        data: bannerModel.toJson(),
        documentId: DateTime.now().millisecondsSinceEpoch
            .toString(), // أو أي UUID
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFaliur(e.toString()));
    }
  }

  @override
  Future<Either<Faliur, List<BannerEntity>>> getBanners() async {
    try {
      final data =
          await databaseService.getData(
                path: BackendPoints.banners,
                query: {'orderBy': 'created_at', 'descending': true},
              )
              as List<Map<String, dynamic>>;

      // تحويل القائمة لـ Entities
      // ملاحظة: الـ FireStoreService عندك بيرجع الداتا، محتاجين نضمن وصول الـ ID
      // لو الـ ID مش جوه الـ map، يفضل تعديل getData لترجع الـ ID أيضاً
      final banners = data.map((e) => BannerModel.fromJson(e, '')).toList();

      return Right(banners);
    } catch (e) {
      return Left(ServerFaliur('فشل في جلب العروض: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Faliur, void>> deleteBanner(BannerEntity banner) async {
    try {
      // 1. حذف البيانات من Firestore
      await databaseService.deleteData(
        path: BackendPoints.banners,
        documentId: banner.id,
      );

      // 2. حذف الصورة من الـ Storage
      // ملاحظة: الـ deleteFile بيحتاج الـ Full Path أو الـ URL حسب تنفيذك
      await storgeService.deleteFile(
        banner.imageUrl,
      ); // لو بتستخدم الـ URL مباشرة محتاج معالجة

      return const Right(null);
    } catch (e) {
      return Left(ServerFaliur('فشل في الحذف: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Faliur, void>> updateBannerStatus(
    String id,
    bool isActive,
  ) async {
    try {
      await databaseService.setData(
        path: BackendPoints.banners,
        id: id,
        data: {'is_active': isActive},
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFaliur('فشل في تحديث الحالة'));
    }
  }
}
