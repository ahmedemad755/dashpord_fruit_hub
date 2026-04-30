import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/featurs/offers/domain/entities/fer_entity.dart';
import '../../domain/repos/offers_repo.dart';
import '../models/offer_model.dart';

class OffersRepoImpl implements OffersRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<OfferEntity>> getOffersStream(String pharmacyId) {
    return _firestore
        .collection('offers')
        .where('pharmacyId', isEqualTo: pharmacyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromJson(doc.data(), doc.id))
            .toList());
  }

@override
Future<void> addOffer(OfferEntity offer) async {
  final batch = FirebaseFirestore.instance.batch();
  
  // 1. مرجع لمستند العرض الجديد
  final offerRef = FirebaseFirestore.instance.collection('offers').doc();
  
  // 2. تحويل الـ Entity لـ Model ثم لـ Json وحفظه
  batch.set(offerRef, OfferModel.fromEntity(offer).toJson());

  // 3. البحث عن المنتجات التابعة لنفس القسم (Category) ونفس الصيدلية
  // ملاحظة: تأكد أن حقل القسم في المنتج اسمه 'category' كما في بياناتك
  if (offer.targetCategory != null) {
    final productsSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: offer.targetCategory) // الربط حسب الكاتيجوري
        .where('pharmacyId', isEqualTo: offer.pharmacyId)     // ضمان الخصوصية للصيدلية
        .get();

    for (var doc in productsSnapshot.docs) {
      // جلب السعر الحالي (السعر الأصلي)
      final double originalPrice = (doc.data()['price'] ?? 0).toDouble();
      
      // حساب السعر الجديد بعد الخصم
      final double discountPercent = offer.discountPercentage.toDouble();
      final double newPrice = originalPrice * (1 - (discountPercent / 100));

      batch.update(doc.reference, {
        'hasDiscount': true,                          // تفعيل الخصم
        'discountPercentage': offer.discountPercentage, // وضع النسبة المئوية
        'price': newPrice,                            // تحديث السعر النهائي ليظهر للعميل
        'offerId': offerRef.id,                       // ربط المنتج بـ ID العرض (لإلغائه لاحقاً)
      });
    }
  }

  // تنفيذ كل التغييرات دفعة واحدة (Atomic Operation)
  await batch.commit();
}

  @override
  Future<void> deleteOffer(String offerId) async {
    await _firestore.collection('offers').doc(offerId).delete();
  }
}