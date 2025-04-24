import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

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
              child:Container(
         margin: EdgeInsets.only(
          left: 20, right: 20, top: context.getHeight(100), bottom: 20),
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
               _buildTabMenu(),
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
                
          )],
              ))),

          ],
        ),
    );
  }
  Widget _buildTabMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == _selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? Colors.green[100] : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      width: isSelected ? 30 : 0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }),
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