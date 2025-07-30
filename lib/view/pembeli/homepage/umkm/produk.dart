import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/widget/produk_grid.dart';

class ProdukUMKM extends StatefulWidget {
  const ProdukUMKM({super.key});

  @override
  State<ProdukUMKM> createState() => _ProdukUMKMState();
}

class _ProdukUMKMState extends State<ProdukUMKM> with WidgetsBindingObserver {
  Key _produkListKey = UniqueKey();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data ketika aplikasi kembali aktif
      _refreshProduk();
    }
  }

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk yang kamu inginkan...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontFamily: "Inter",
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                searchQuery: _searchQuery,
                showDeletedProducts:
                    false)), // Hanya tampilkan produk yang tidak dihapus
      ],
    );
  }
}
