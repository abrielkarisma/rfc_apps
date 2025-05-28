import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/user.dart';
import 'package:rfc_apps/widget/list_penjual.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<dynamic> _penjualList = [];
  int requestCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPenjual();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchPenjual();
    });
  }

  Future<void> _fetchPenjual() async {
    try {
      final response = await UserService().getAllPenjual();
      final data = response['data'] ?? [];
      final inactiveCount = data
          .where((item) =>
              item['Toko'] != null && item['Toko']['tokoStatus'] == 'request')
          .length;
      final filtered = data.where((e) {
        print(
            "Toko status: ${e['Toko']?['tokoStatus']}");
        return e['Toko'] != null && e['Toko']['tokoStatus'] == 'active';
      }).toList();
      setState(() {
        _penjualList = filtered;
        requestCount = inactiveCount;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            height: context.getHeight(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/user_request');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Daftar Permintaan Registrasi Penjual",
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    height: context.getHeight(32),
                    width: context.getWidth(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                      color: const Color(0xFF6BC0CA),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        requestCount.toString(),
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LineIcons.angleRight),
                    onPressed: () {
                      Navigator.pushNamed(context, '/user_list');
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.getHeight(60)),
          const Text(
            "Daftar Toko",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6BC0CA),
            ),
          ),
          SizedBox(height: context.getHeight(16)),
          PenjualTable(penjualList: _penjualList, onDelete: true,),
          SizedBox(height: context.getHeight(16)),
          Container(
            padding: const EdgeInsets.all(8),
            height: context.getHeight(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                _modalLogout(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LineIcons.alternateSignOut,
                      color: Colors.red,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _modalLogout(BuildContext context) {
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
                  final tokenStorage = FlutterSecureStorage();
                  tokenStorage.deleteAll();
                  tokenStorage.delete(key: 'token');
                  tokenStorage.delete(key: 'refreshToken');
                  tokenStorage.delete(key: 'role');
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
}
