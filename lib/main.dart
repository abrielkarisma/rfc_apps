import 'package:flutter/material.dart';
import 'package:rfc_apps/view/auth/auth.dart';
import 'package:rfc_apps/view/homepage/homepage.dart';
import 'package:rfc_apps/view/onboarding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RFC Apps',
      theme: ThemeData(
        primaryColor: Color(0XFF4CAD73),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
