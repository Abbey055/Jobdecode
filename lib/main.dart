import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/jobdecode_app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: JobDecodeApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(AppConfig.initializeSupabase());
  });
}
