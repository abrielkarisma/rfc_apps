import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class Histori extends StatefulWidget {
  const Histori({super.key});

  @override
  State<Histori> createState() => _HistoriState();
}

class _HistoriState extends State<Histori> {
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
            child: Text("Riwayat Pesanan",
                style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.start),
          ),
  ])
    );
  }
}
