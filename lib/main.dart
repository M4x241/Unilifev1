import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/pages/loading_page.dart';
import 'package:unilife/pages/login_page.dart';
import 'package:unilife/pages/main_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'UniLife',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/loading',
        routes: {
          '/loading': (context) => LoadingPage(),
          '/login': (context) => LoginPage(),
          '/main': (context) => MainPage(),
        },
      ),
    );
  }
}
