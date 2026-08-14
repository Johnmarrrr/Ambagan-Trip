import 'package:flutter/material.dart';
import 'package:ambagan_trip/app/router.dart';
import 'package:ambagan_trip/core/theme/app_theme.dart';

class AmbaganApp extends StatelessWidget {
  const AmbaganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ambagan Trip',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
