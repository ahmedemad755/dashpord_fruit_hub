import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/repos/imag_repo/imag_repo.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';

class ImagRepoImp implements ImagRepo {
  final StorgeService storgeService;
  ImagRepoImp(this.storgeService);
  @override
  Future<Either<Faliur, String>> uploadImage(File image) async {
    try {
      return await storgeService.uploadImage(image, BackendPoints.urlImag).then((
        value,
      ) {
        if (value == null) {
          return left(
            ServerFaliur(
              'server error image is null or failed to upload so its uploaded already',
            ),
          );
        }
        return right(value);
      });
    } catch (e) {
      return left(ServerFaliur('server error to upload image'));
    }
  }
}
