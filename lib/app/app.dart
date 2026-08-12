import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/services/preferences_service.dart';
import 'app_router.dart';
import 'app_theme.dart';

/// The root widget.
///
/// Deliberately thin: it wires the theme and the router and nothing else. All
/// startup work happens in `bootstrap.dart` before this widget is ever built,
/// so there is no loading state to render here.
class SelahApp extends ConsumerWidget {
  const SelahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
