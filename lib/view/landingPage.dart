import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'refreshToken');
    String? role = await storage.read(key: 'role');

    String route;
    if (token != null && role != null) {
      if (role == 'user') {
        route = '/homepage';
      } else if (role == 'penjual') {
        route = '/home_seller';
      } else if (role == 'admin') {
        route = '/login_admin';
      } else {
        route = '/onboarding';
      }
    } else {
      route = '/onboarding';
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SvgPicture.asset(
          'assets/images/RFC.svg',
          width: 200,
        ),
      ),
    );
  }
}
