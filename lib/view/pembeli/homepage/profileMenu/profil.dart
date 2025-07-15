import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/token.dart';
import 'package:rfc_apps/service/user.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

String userId = "";
String $name = "";
String $email = "";
String $phone = "";
String $avatarUrl = "";

class _ProfilState extends State<Profil> {
  @override
  void initState() {
    super.initState();
    _getUserDatabyId();
  }

  void _getUserDatabyId() async {
    try {
      final getId = await tokenService().getUserId();
      final user = await UserService().getUserById(getId!);
      final name = user.data?['name'] ?? '';
      final email = user.data?['email'] ?? '';
      final phone = user.data?['phone'] ?? '';
      final avatarUrl = user.data?['avatarUrl'] ?? '';

      setState(() {
        $name = name;
        $email = email;
        $phone = phone;
        userId = getId;
        $avatarUrl = avatarUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pengguna: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: 20, right: 20, top: context.getHeight(100), bottom: 20),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text("Profil",
                style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.start),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: context.getWidth(100),
                          height: context.getHeight(100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[200]!,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                              child: $avatarUrl.endsWith('.svg')
                                  ? SvgPicture.network(
                                      $avatarUrl,
                                      fit: BoxFit.cover,
                                      placeholderBuilder:
                                          (BuildContext context) => Container(
                                        padding: const EdgeInsets.all(20),
                                        child:
                                            const CircularProgressIndicator(),
                                      ),
                                    )
                                  : Image.network(
                                      $avatarUrl,
                                      fit: BoxFit.cover,
                                    )),
                        ),
                        SizedBox(height: context.getHeight(7)),
                        Text(
                          $name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),
                        SizedBox(height: context.getHeight(1)),
                        Text(
                          $email,
                          style: TextStyle(
                            color: Color(0xFF979797),
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.getHeight(22)),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/edit_profile',
                              arguments: {
                                'name': $name,
                                'email': $email,
                                'phone': $phone,
                                'userId': userId,
                                'avatarUrl': $avatarUrl,
                              },
                            );
                            if (result == 'refresh') {
                              _getUserDatabyId();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.getHeight(27)),
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMenuItem('assets/images/menuIcon/profile.png',
                              'Saldo Pengguna',
                              onTapRoute: '/saldo', context: context),
                          SizedBox(height: 16),
                          _buildMenuItem('assets/images/menuIcon/lock.png',
                              'Ubah Password',
                              onTapRoute: '/lupa_password',
                              routeArguments: 'ganti',
                              context: context),
                          SizedBox(height: 16),
                          _buildMenuItem('assets/images/menuIcon/star.png',
                              'Beri Rating Kami',
                              onTapRoute: '/tnc', context: context),
                          SizedBox(height: 16),
                          _buildMenuItem('assets/images/menuIcon/docs.png',
                              'Syarat & Ketentuan',
                              onTapRoute: '/tnc', context: context),
                          SizedBox(height: 16),
                          _buildMenuItem('assets/images/menuIcon/docs.png',
                              'Kebijakan Privasi',
                              onTapRoute: '/privacy_policy', context: context),
                          SizedBox(height: 16),
                          _buildLogoutItem(context),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(String assetPath, String title,
      {required String onTapRoute,
      String? routeArguments,
      required BuildContext context}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Image.asset(
          assetPath,
          width: 48,
          height: 48,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Color(0xFF979797)),
        onTap: () {
          Navigator.pushNamed(context, onTapRoute, arguments: routeArguments);
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Image.asset(
          'assets/images/menuIcon/logout.png',
          width: 48,
          height: 48,
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Color(0xFF979797)),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            backgroundColor: Colors.white,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apakah kamu yakin akan keluar dari akun?',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFEAEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          final tokenStorage = FlutterSecureStorage();
                          tokenStorage.delete(key: 'token');
                          tokenStorage.delete(key: 'refreshToken');
                          tokenStorage.delete(key: 'role');
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/auth',
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text(
                          'Ya, Logout',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Color(0xFF979797),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
