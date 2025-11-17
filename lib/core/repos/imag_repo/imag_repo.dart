import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';

abstract class ImagRepo {
  Future<Either<Faliur, String>> uploadImage(File image);
}
