import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/produk.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/toko.dart';
import 'package:rfc_apps/widget/tab_menu.dart';

class UMKMToko extends StatefulWidget {
  const UMKMToko({super.key});

  @override
  State<UMKMToko> createState() => _UMKMTokoState();
}

class _UMKMTokoState extends State<UMKMToko> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _tabs = ['Produk', 'Toko'];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 20),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text("UMKM ",
                style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.start),
          ),
          SizedBox(height: context.getHeight(26)),
          TabMenu(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            pageController: _pageController,
            onTabChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                ProdukUMKM(),
                TokoUmkm(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
