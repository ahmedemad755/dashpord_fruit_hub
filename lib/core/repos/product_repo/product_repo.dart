import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';

abstract class ProductRepo {
  Future<Either<Faliur, String>> addProduct(AddProductIntety addProductIntety);
}
