import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/theme.dart';
import 'package:repair_shop/features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Repair Shop",
      theme: AppTheme.darkThemeMode,
      home: const LoginPage(),
    );
  }
}
