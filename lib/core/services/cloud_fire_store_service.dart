import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';

class FireStoreService implements DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ---------------------------- Helpers ---------------------------- //

  /// Apply query modifiers like orderBy, limit...
  Query<Map<String, dynamic>> _applyQueryModifiers(
    Query<Map<String, dynamic>> query,
    Map<String, dynamic>? queryParams,
  ) {
    if (queryParams == null) return query;

    if (queryParams['orderBy'] != null) {
      query = query.orderBy(
        queryParams['orderBy'],
        descending: queryParams['descending'] ?? false,
      );
    }

    if (queryParams['limit'] != null) {
      query = query.limit(queryParams['limit']);
    }

    return query;
  }

  // ---------------------------- CRUD ---------------------------- //

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    required String documentId,
  }) async {
    await firestore.collection(path).doc(documentId).set(data);
  }

  @override
  Future<void> setData({
    required String path,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(path).doc(id).set(data, SetOptions(merge: true));
  }

  @override
  Future<bool> checkIfDataExists({
    required String documentId,
    required String path,
  }) async {
    final doc = await firestore.collection(path).doc(documentId).get();
    return doc.exists;
  }

  // ---------------------------- READ ---------------------------- //

  @override
  Future<List<Map<String, dynamic>>> getData({
    required String path,
    String? docuementId,
    Map<String, dynamic>? query,
  }) async {
    // Get Single Document
    if (docuementId != null) {
      final doc = await firestore.collection(path).doc(docuementId).get();
      return doc.exists ? [doc.data()!] : [];
    }

    // Get Multiple Documents
    Query<Map<String, dynamic>> ref = firestore.collection(path);

    ref = _applyQueryModifiers(ref, query);

    final result = await ref.get();

    return result.docs.map((e) => e.data()).toList();
  }

  // ---------------------------- STREAM ---------------------------- //

  @override
  Stream<List<Map<String, dynamic>>> getDataStream({
    required String path,
    Map<String, dynamic>? query,
  }) {
    Query<Map<String, dynamic>> ref = firestore.collection(path);

    ref = _applyQueryModifiers(ref, query);

    return ref.snapshots().map(
      (snapshot) => snapshot.docs.map((e) => e.data()).toList(),
    );
  }

  @override
  Future<void> updateOrder({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(path).doc(documentId).update(data);
  }
}
