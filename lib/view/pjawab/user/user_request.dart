import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/user.dart';
import 'package:rfc_apps/widget/list_penjual.dart';

class UserRequest extends StatefulWidget {
  const UserRequest({Key? key}) : super(key: key);

  @override
  State<UserRequest> createState() => _UserRequestState();
}

class _UserRequestState extends State<UserRequest> {
  List<dynamic> _penjualList = [];
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

      final filtered = data.where((e) {
        print("Toko status: ${e['Toko']?['tokoStatus']}");
        return e['Toko'] != null && e['Toko']['tokoStatus'] == 'request';
      }).toList();

      setState(() {
        _penjualList = filtered;
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
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Rooftop Farming Center.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "Monserrat_Alternates",
                  fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: SvgPicture.asset(
              "assets/images/admin_background.svg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Daftar Permintaan",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.getHeight(100)),
              Container(
                child: PenjualTable(penjualList: _penjualList, onDelete: false),
              ),
            ]),
          ),
        ]));
  }
}
