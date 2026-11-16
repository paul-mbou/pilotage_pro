import 'package:pilotage_pro/data/repositories/firestore/firestore_repositories.dart';
import 'package:pilotage_pro/domain/entities/entities.dart';

class FirestoreSeedService {
  FirestoreSeedService({
    required this.userRepository,
    required this.locationRepository,
    required this.categoryRepository,
  });

  final UserRepository userRepository;
  final LocationRepository locationRepository;
  final CategoryRepository categoryRepository;

  Future<void> seedIfEmpty() async {
    final locations = await locationRepository.getAll();
    if (locations.isEmpty) {
      await locationRepository.upsert(
        Location(
          id: 'loc_1',
          name: 'Magasin Principal',
          address: 'Centre-ville',
          isActive: true,
        ),
      );
      await locationRepository.upsert(
        Location(
          id: 'loc_2',
          name: 'Annexe',
          address: 'Zone commerciale',
          isActive: true,
        ),
      );
    }

    final categories = await categoryRepository.getAll();
    if (categories.isEmpty) {
      await categoryRepository.upsert(
        Category(
          id: 'cat_1',
          name: 'Boissons',
          description: 'Boissons fraiches et gazeuses',
        ),
      );
      await categoryRepository.upsert(
        Category(
          id: 'cat_2',
          name: 'Alimentaire',
          description: 'Produits alimentaires',
        ),
      );
      await categoryRepository.upsert(
        Category(
          id: 'cat_3',
          name: 'Services',
          description: 'Prestations et services',
        ),
      );
    }

    final users = await userRepository.getAll();
    if (users.isEmpty) {
      await userRepository.upsert(
        User(
          id: 'user_1',
          name: 'Rostand MOUNGAM',
          email: 'rostand@pilotage.pro',
          role: UserRole.admin,
          locationId: 'loc_1',
          isActive: true,
        ),
      );
      await userRepository.upsert(
        User(
          id: 'user_2',
          name: 'Marie KOUAM',
          email: 'marie@pilotage.pro',
          role: UserRole.caissier,
          locationId: 'loc_1',
          isActive: true,
        ),
      );
    }
  }
}
