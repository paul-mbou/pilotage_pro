import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Image chargée depuis une URL (http/https) avec **cache disque + mémoire**.
///
/// Préférer ce widget à [Image.network] partout dans l’app pour limiter
/// l’usage réseau, accélérer l’affichage et éviter de re-télécharger les
/// mêmes ressources.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.httpHeaders,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 200),
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;
  final Map<String, String>? httpHeaders;

  /// Affiché au tout premier chargement, avant tout octet reçu.
  /// Ne pas combiner avec [progressIndicatorBuilder] (règle du package).
  final PlaceholderWidgetBuilder? placeholder;

  /// Indique la progression du téléchargement. Si fourni, ne pas fournir [placeholder].
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  final LoadingErrorWidgetBuilder? errorWidget;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = height;
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: w,
      height: h,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      httpHeaders: httpHeaders,
      // Redimensionnement mémoire (dpr × taille) retiré : sur certains appareils
      // cela provoquait un décodage bloqué / spinner infini. Le cache disque
      // [CachedNetworkImage] reste actif. Réactiver avec clamp 1..4096 si besoin.
      fadeInDuration: fadeInDuration,
      placeholder: placeholder,
      progressIndicatorBuilder: progressIndicatorBuilder,
      errorWidget: errorWidget,
    );
  }
}
