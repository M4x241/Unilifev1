import 'package:flutter/material.dart';
import 'package:unilife/pages/loading_page.dart';
import 'package:unilife/pages/login_page.dart';
import 'package:unilife/pages/main_page.dart';
import 'package:unilife/pages/menu_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unilife',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
        '/login': (context) => LoginPage(),
        '/main': (context) => MainPage(),
        '/menu': (context) => MenuPage(),
      },
    );
  }
}
