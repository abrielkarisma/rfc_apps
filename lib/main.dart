import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfc_apps/view/auth/auth.dart';
import 'package:rfc_apps/view/landingPage.dart';
import 'package:rfc_apps/view/auth/login.dart';
import 'package:rfc_apps/view/auth/lupaPassword.dart';
import 'package:rfc_apps/view/pembeli/homepage/keranjang/keranjang.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/nota.dart';
import 'package:rfc_apps/view/pembeli/homepage/produk/detail_produk.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/tokoInformation.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/tokoProduk.dart';
import 'package:rfc_apps/view/penjual/komoditas.dart';
import 'package:rfc_apps/view/penjual/detail_komoditas.dart';
import 'package:rfc_apps/view/penjual/penjualan/detailPendapatan.dart';
import 'package:rfc_apps/view/penjual/penjualan/riwayatPenjualan.dart';
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
import 'package:rfc_apps/view/penjual/pesanan/daftar_pesanan.dart';
import 'package:rfc_apps/view/penjual/home.dart';
import 'package:rfc_apps/view/penjual/profil_seller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rfc_apps/view/pjawab/home.dart';
import 'package:rfc_apps/view/pjawab/user/user_request.dart';
import 'package:rfc_apps/view/saldo/riwayatMutasi.dart';
import 'package:rfc_apps/view/saldo/saldoUser.dart';
import 'package:rfc_apps/view/saldo/tarikSaldo.dart';
import 'package:rfc_apps/view/saldo/informasiRekening.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCgyn7fy5R-flroGtPU2-mHR6gEuiMGUxQ",
      appId: "1:15806207070:android:0d76922695a396f78950cf",
      messagingSenderId: "15806207070",
      projectId: "farmcenter-61683",
    ),
  );

}

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCgyn7fy5R-flroGtPU2-mHR6gEuiMGUxQ",
      appId: "1:15806207070:android:0d76922695a396f78950cf",
      messagingSenderId: "15806207070",
      projectId: "farmcenter-61683",
    ),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'RFC Apps',
      theme: ThemeData(
        primaryColor: Color(0XFF4CAD73),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/auth': (context) => AuthScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) =>
            LoginPembeliWidget(pageController: PageController()),
        '/pjawab_home': (context) => PjawabHome(),
        '/homepage': (context) => Homepage(),
        '/profil': (context) => Homepage(initialIndex: 4),
        '/change_password': (context) => changePassword(),
        '/privacy_policy': (context) => privacyP(),
        '/tnc': (context) => termsAndConditions(),
        '/home_seller': (context) => homeSeller(),
        '/toko_register': (context) => Sellerstorereg(),
        '/profil_seller': (context) => profileSeller(),
        '/daftar_pesanan': (context) {
          final tokoId = ModalRoute.of(context)!.settings.arguments as String;
          return DaftarPesanan(tokoId: tokoId);
        },
        '/kelola_produk': (context) => KelolaProduk(),
        '/tambah_produk': (context) => TambahProduk(),
        '/lupa_password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
  return LupaPasswordPage(from: args);
        },
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
        '/bukti_pembayaran': (context) {
          final data = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PaymentSuccessPage(data: data);
        },
        '/user_request': (context) => UserRequest(),
        '/penjualan': (context) {
          final idToko = ModalRoute.of(context)!.settings.arguments as String;
          return riwayatPenjualan(
            tokoId: idToko,
          );
        },
        '/detail_pendapatan': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return Pendapatan(
            Id: args['Id'] as String,
          );
        },
        '/saldo': (context) => SaldoPage(),
        '/komoditas': (context) => Komoditas(),
        '/detail_komoditas': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return DetailKomoditasPage(id: id);
        },
        '/mutasi_saldo': (context) => RiwayatMutasiPage(),
        '/informasi_rekening': (context) => const InformasiRekeningPage(),
      },
    );
  }
}
