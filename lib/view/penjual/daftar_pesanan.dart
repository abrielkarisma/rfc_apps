import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/widget/tab_menu.dart';

class DaftarPesanan extends StatefulWidget {
  const DaftarPesanan({super.key});

  @override
  State<DaftarPesanan> createState() => _DaftarPesananState();
}

class _DaftarPesananState extends State<DaftarPesanan> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _tabs = ['Pesanan Masuk', 'Menunggu Diambil', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/homebackground.png',
              fit: BoxFit.fill,
            ),
          ),
          Container(
              child: Container(
                  margin: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: context.getHeight(100),
                      bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daftar Pesanan",
                          style: TextStyle(
                              fontFamily: "poppins",
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.start),
                      const SizedBox(height: 50),
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
                            _buildPage("Ini adalah halaman SEMUA"),
                            _buildPage("Ini adalah halaman AKTIF"),
                            _buildPage("Ini adalah halaman SELESAI"),
                          ],
                        ),
                      )
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget _buildPage(String content) {
    return Center(
      child: Text(
        content,
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
