import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/widget/produk_grid.dart';

class ProdukUMKM extends StatefulWidget {
  const ProdukUMKM({super.key});

  @override
  State<ProdukUMKM> createState() => _ProdukUMKMState();
}

class _ProdukUMKMState extends State<ProdukUMKM> {
  Key _produkListKey = UniqueKey();
  String _searchQuery = '';

  void _refreshProduk() {
    setState(() {
      _produkListKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: context.getHeight(50),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk UMKM',
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(height: context.getHeight(20)),
        Expanded(
            child: ProdukGrid(
                key: _produkListKey,
                cardType: "umkm",
                id: "",
                searchQuery: _searchQuery)),
      ],
    );
  }
}
