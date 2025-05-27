import 'dart:async';

import 'package:flutter/material.dart';
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
      final inactiveCount =
          data.where((item) => item['is_active'] == false).length;
      setState(() {
        _penjualList = response['data'] ?? [];
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
          PenjualTable(penjualList: _penjualList),
        ],
      ),
    );
  }
}
