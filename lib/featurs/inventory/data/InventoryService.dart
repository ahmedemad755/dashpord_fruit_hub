import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> decreaseProductStock(OrderEntity order) async {
    // نستخدم WriteBatch لتحديث جميع المنتجات في عملية واحدة
    WriteBatch batch = _firestore.batch();

    for (var product in order.orderProducts) {
      // 1. تحديد مرجع المنتج في كولكشن 'products'
      // ⚠️ تأكد أن product.id هو نفسه الـ Document ID في كولكشن المنتجات
      DocumentReference productRef = _firestore
          .collection('products')
          .doc(product.code);

      // 2. تحديث الكمية (إنقاصها)
      batch.update(productRef, {
        'unitAmount': FieldValue.increment(-product.quantity),
      });
    }

    // 3. تنفيذ العمليات دفعة واحدة
    await batch.commit();
  }
}
