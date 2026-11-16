# Pilotage Pro — notes pour agents / contributeurs

## Images chargées depuis le réseau (http / https)

- Utiliser **`AppNetworkImage`** (`lib/core/widgets/app_network_image.dart`), basé sur **`cached_network_image`**, pour toute URL distante (avatars, photos produit, etc.).
- **Ne pas** utiliser `Image.network` ni `NetworkImage` directs pour ces cas : pas de cache disque par défaut, plus de trafic et listes moins fluides.
- Les images **locales** (`Image.asset`, `AssetImage`) ne sont pas concernées.

## Dépendance

- `cached_network_image` est déclaré dans `pubspec.yaml` ; ne pas dupliquer une autre lib de cache images sans bonne raison.
