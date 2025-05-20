import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfc_apps/view/auth/auth.dart';
import 'package:rfc_apps/view/landingPage.dart';
import 'package:rfc_apps/view/auth/login.dart';
import 'package:rfc_apps/view/auth/login_admin.dart';
import 'package:rfc_apps/view/auth/lupaPassword.dart';
import 'package:rfc_apps/view/pembeli/homepage/keranjang/keranjang.dart';
import 'package:rfc_apps/view/pembeli/homepage/produk/detail_produk.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/tokoInformation.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/tokoProduk.dart';
import 'package:rfc_apps/view/penjual/produk/detail_produk.dart';
import 'package:rfc_apps/view/penjual/produk/kelola_produk.dart';
import 'package:rfc_apps/view/penjual/produk/tambah_produk.dart';
import 'package:rfc_apps/view/penjual/sellerStoreReg.dart';
import 'package:rfc_apps/view/pembeli/homepage/homepage.dart';
import 'package:rfc_apps/view/onboarding.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/profil.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/changePassword.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/editProfile.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/privacy.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/setting.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/tnc.dart';
import 'package:rfc_apps/view/penjual/daftar_pesanan.dart';
import 'package:rfc_apps/view/penjual/home.dart';
import 'package:rfc_apps/view/penjual/profil_seller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingPage(),
        '/': (context) => Homepage(),
        '/auth': (context) => AuthScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) =>
            LoginPembeliWidget(pageController: PageController()),
        '/login_admin': (context) => LoginAdmin(),
        '/homepage': (context) => Homepage(),
        '/profil': (context) => Homepage(initialIndex: 4),
        '/change_password': (context) => changePassword(),
        '/privacy_policy': (context) => privacyP(),
        '/tnc': (context) => termsAndConditions(),
        '/home_seller': (context) => homeSeller(),
        '/toko_register': (context) => Sellerstorereg(),
        '/profil_seller': (context) => profileSeller(),
        '/daftar_pesanan': (context) => DaftarPesanan(),
        '/kelola_produk': (context) => KelolaProduk(),
        '/tambah_produk': (context) => TambahProduk(),
        '/lupa_password': (context) => LupaPasswordPage(),
        '/detail_produk_buyer': (context) {
          final idProduk = ModalRoute.of(context)!.settings.arguments as String;
          return DetailProdukBuyer(idProduk: idProduk);
        },
        '/detail_produk': (context) {
          final idProduk = ModalRoute.of(context)!.settings.arguments as String;
          return DetailProdukPage(id_produk: idProduk);
        },
        '/edit_profile': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return EditProfile(
            name: args['name'] ?? '',
            email: args['email'] ?? '',
            phone: args['phone'] ?? '',
            userId: args['userId'] ?? '',
            avatarUrl: args['avatarUrl'] ?? '',
          );
        },
        '/toko_detail': (context) {
          final idToko = ModalRoute.of(context)!.settings.arguments as String;
          return TokoInformation(tokoId: idToko);
        },
        '/toko_produk': (context) {
          final idToko = ModalRoute.of(context)!.settings.arguments as String;
          return ProdukToko(idToko: idToko);
        },
        '/keranjang': (context) => Keranjang(),
      },
    );
  }
}
