import 'package:pilotage_pro/data/baas/database/document_store.dart';

class NoopDocumentStore implements DocumentStore {
  @override
  Future<List<DocumentRecord>> getAll({required String collection}) async =>
      const [];

  @override
  Future<void> delete({required String collection, required String id}) async {}

  @override
  Future<Map<String, dynamic>?> getById({
    required String collection,
    required String id,
  }) async =>
      null;

  @override
  Future<void> upsert({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {}
}
