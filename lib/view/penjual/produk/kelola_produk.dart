import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/widget/produk_card_seller.dart';
import 'package:rfc_apps/widget/produk_grid.dart';

class KelolaProduk extends StatefulWidget {
  const KelolaProduk({super.key});

  @override
  State<KelolaProduk> createState() => _KelolaProdukState();
}

class _KelolaProdukState extends State<KelolaProduk> {
  Key _produkListKey = UniqueKey();
  void _refreshProduk() {
    setState(() {
      _produkListKey = UniqueKey(); // trigger rebuild ProdukList
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Rooftop Farming Center.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/homebackground.png',
            fit: BoxFit.fill,
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Kelola Produk",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.getHeight(50)),
              Expanded(child: ProdukGrid(key: _produkListKey, cardType: "kelola", id: "",)),
              SizedBox(height: context.getHeight(47)),
            ]))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/tambah_produk',
          );
          if (result == 'refresh') {
            _refreshProduk();
          }
        },
        backgroundColor: Color(0XFF4CAD73),
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
