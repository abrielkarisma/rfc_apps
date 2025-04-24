import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
              children: [
                Column(
                  children: [
                      Container(
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
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ),
                     SizedBox(height: context.getHeight(7)),
                    const Text(
                      'Abriel Karisma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(height: context.getHeight(1)),
                    const Text(
                      'abrielcha.ac@gmail.com',
                      style: TextStyle(
                        color: Color(0xFF979797),
                        fontFamily: "Poppins",
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.getHeight(22)),
                    ElevatedButton(
                      onPressed: () {
                        print("edit profile ditekan");
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
                        style: TextStyle(fontFamily: "Poppins",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox( height: context.getHeight(27)),
                Container(
                  width: double.infinity,
                  height: context.getHeight(464),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                   _buildMenuItem('assets/images/menuIcon/profile.png', 'Pengaturan Akun', onTapRoute: '/account_setting', context: context ),
                  _buildMenuItem('assets/images/menuIcon/lock.png', 'Ubah Password', onTapRoute: '/change_password', context: context),
                  _buildMenuItem('assets/images/menuIcon/star.png', 'Beri Rating Kami', onTapRoute: '/tnc', context: context),
                  _buildMenuItem('assets/images/menuIcon/docs.png', 'Syarat & Ketentuan', onTapRoute: '/tnc', context: context),
                  _buildMenuItem('assets/images/menuIcon/docs.png', 'Kebijakan Privasi', onTapRoute: '/privacy_policy', context: context),
                  _buildLogoutItem(context),
                  ],),
                )
               ],
                      ),
            ),
          ),  
        ], 
      ),
    );
  }

  Widget _buildMenuItem(String assetPath, String title, {Color? iconColor,  required String onTapRoute, required BuildContext context}) {
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
        height: 48,),
        title: Text(
          title,
          style: const TextStyle(fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF979797)),
        onTap: () {
          Navigator.pushNamed(context, onTapRoute);
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
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF979797)),
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
