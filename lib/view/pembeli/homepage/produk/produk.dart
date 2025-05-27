import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/widget/produk_grid.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  Key _produkListKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: context.getHeight(50)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: context.getWidth(300), // Set your desired width
              height: context.getHeight(50), // Set your desired height
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                ),
                onChanged: (value) {},
              ),
            ),
            SizedBox(width: context.getWidth(16)),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/keranjang");
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: SvgPicture.asset("assets/images/cart_white.svg"),
              ),
            )
          ],
        ),
        SizedBox(height: context.getHeight(50)),
        Expanded(
            child: ProdukGrid(key: _produkListKey, cardType: "rfc", id: "")),
      ]),
    );
  }
}
