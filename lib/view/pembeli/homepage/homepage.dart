import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rfc_apps/view/pembeli/homepage/artikel.dart';
import 'package:rfc_apps/view/pembeli/homepage/histori.dart';
import 'package:rfc_apps/view/pembeli/homepage/home.dart';
import 'package:rfc_apps/view/pembeli/homepage/produk.dart';
import 'package:rfc_apps/view/pembeli/homepage/profil.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  void _onSeeMoreArticles() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onSeeMoreProducts() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  late final List<Widget> _widgetOptions = <Widget>[
    Home(
      onSeeMoreArticles: _onSeeMoreArticles,
      onSeeMoreProducts: _onSeeMoreProducts,
    ),
    ArtikelScreen(),
    Produk(),
    Histori(),
    Profil(),
  ];

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
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 28,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Theme.of(context).primaryColor,
            color: Theme.of(context).primaryColor,
            tabs: [
              GButton(
                icon: LineIcons.home,
                text: 'Beranda',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
              GButton(
                icon: LineIcons.paperclip,
                text: 'Artikel',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
              GButton(
                icon: LineIcons.store,
                text: 'Produk',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
              GButton(
                icon: LineIcons.history,
                text: 'Histori',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
              GButton(
                icon: LineIcons.user,
                text: 'Profil',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ));
  }
}
