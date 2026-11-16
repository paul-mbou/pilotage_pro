import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newEntityId() => _uuid.v4();
