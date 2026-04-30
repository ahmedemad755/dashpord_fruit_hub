
import 'package:fruitesdashboard/featurs/offers/domain/entities/fer_entity.dart';

abstract class OffersRepo {
  // استخدام Stream لجعل الواجهة دايناميك وتحدث تلقائياً
  Stream<List<OfferEntity>> getOffersStream(String pharmacyId);
  Future<void> addOffer(OfferEntity offer);
  Future<void> deleteOffer(String offerId);
}