class DocumentRecord {
  const DocumentRecord({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, dynamic> data;
}

abstract class DocumentStore {
  Future<List<DocumentRecord>> getAll({
    required String collection,
  });

  Future<Map<String, dynamic>?> getById({
    required String collection,
    required String id,
  });

  Future<void> upsert({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<void> delete({
    required String collection,
    required String id,
  });
}
