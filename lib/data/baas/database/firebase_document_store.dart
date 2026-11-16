import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilotage_pro/data/baas/database/document_store.dart';

class FirebaseDocumentStore implements DocumentStore {
  FirebaseDocumentStore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<DocumentRecord>> getAll({
    required String collection,
  }) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs
          .map(
            (doc) => DocumentRecord(
              id: doc.id,
              data: doc.data(),
            ),
          )
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<void> delete({
    required String collection,
    required String id,
  }) {
    return _firestore.collection(collection).doc(id).delete();
  }

  @override
  Future<Map<String, dynamic>?> getById({
    required String collection,
    required String id,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      return doc.data();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> upsert({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection(collection).doc(id).set(data);
  }
}
