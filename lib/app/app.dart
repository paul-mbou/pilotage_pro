import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pilotage_pro/app/providers/providers.dart';
import 'package:pilotage_pro/app/router/app_router.dart';
import 'package:pilotage_pro/core/theme/app_theme.dart';

/// Root widget: theme, routing, Riverpod scope is above in [main].
class PilotageProApp extends ConsumerStatefulWidget {
  const PilotageProApp({super.key});

  @override
  ConsumerState<PilotageProApp> createState() => _PilotageProAppState();
}

class _PilotageProAppState extends ConsumerState<PilotageProApp> {
  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Pilotage Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: appRouter,
    );
  }
}
