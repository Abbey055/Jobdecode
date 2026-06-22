import 'package:flutter/material.dart';

import '../shared/theme/app_theme.dart';
import 'router.dart';

class JobDecodeApp extends StatelessWidget {
  const JobDecodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JobDecode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
