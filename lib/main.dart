import 'package:flutter/material.dart';
import 'package:rfc_apps/view/auth/auth.dart';
import 'package:rfc_apps/view/auth/login_admin.dart';
import 'package:rfc_apps/view/auth/lupaPassword.dart';
import 'package:rfc_apps/view/pembeli/homepage/homepage.dart';
import 'package:rfc_apps/view/onboarding.dart';
import 'package:rfc_apps/view/pembeli/homepage/profil.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/changePassword.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/privacy.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/setting.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/tnc.dart';
import 'package:rfc_apps/view/penjual/daftar_pesanan.dart';
import 'package:rfc_apps/view/penjual/home.dart';
import 'package:rfc_apps/view/penjual/profil_seller.dart';

void main() async {
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
      initialRoute: '/onboarding',
      routes: {
        '/': (context) => Homepage(),
        '/auth': (context) => AuthScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login_admin': (context) => LoginAdmin(),
        '/homepage': (context) => Homepage(),
        '/profil': (context) => Profil(),
        '/account_setting': (context) => accountSetting(),
        '/change_password': (context) => changePassword(),
        '/privacy_policy': (context) => privacyP(), 
        '/tnc': (context) => termsAndConditions(),
        '/home_seller': (context) => homeSeller(),
        '/profil_seller': (context) => profileSeller(),
        '/daftar_pesanan': (context) => DaftarPesanan(),
        '/lupa_password': (context) => LupaPasswordPage(),
      },
    );
  }
}
