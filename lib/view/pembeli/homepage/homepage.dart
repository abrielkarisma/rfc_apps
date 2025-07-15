import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rfc_apps/view/pembeli/homepage/artikel.dart';
import 'package:rfc_apps/view/pembeli/homepage/histori.dart';
import 'package:rfc_apps/view/pembeli/homepage/home.dart';
import 'package:rfc_apps/view/pembeli/homepage/produk/produk.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/profil.dart';
import 'package:rfc_apps/view/pembeli/homepage/umkm/umkm.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late int _selectedIndex;

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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  late final List<Widget> _widgetOptions = <Widget>[
    Home(
      onSeeMoreArticles: _onSeeMoreArticles,
      onSeeMoreProducts: _onSeeMoreProducts,
    ),
    UMKMToko(),
    ProdukPage(),
    Histori(),
    Profil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 4,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  duration: Duration(milliseconds: 300),
                  tabBackgroundColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).primaryColor,
                  tabs: [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Beranda',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.store,
                      text: 'UMKM',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.shoppingBasket,
                      text: 'Produk',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.history,
                      text: 'Histori',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.user,
                      text: 'Profil',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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
              ),
            )));
  }
}
