import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/artikel.dart';
import 'package:rfc_apps/service/artikel.dart';
import 'package:rfc_apps/widget/carousel_artikel.dart';

class Home extends StatefulWidget {
  final VoidCallback onSeeMoreArticles;
  final VoidCallback onSeeMoreProducts;

  const Home(
      {super.key,
      required this.onSeeMoreArticles,
      required this.onSeeMoreProducts});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
            child: Text("Home",
                style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.start),
          ),
          Padding(padding: EdgeInsets.only(top: context.getHeight(59))),
          Container(
            child: FutureBuilder<List<Artikel>>(
              future: fetchArtikel(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found'));
                } else {
                  List<Artikel> items = snapshot.data!;
                  return ArtikelCarousel(artikels: items);
                }
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(top: context.getHeight(13))),
          Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lihat lebih banyak artikel",
                    style: TextStyle(
                        fontFamily: "poppins",
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: widget.onSeeMoreArticles,
                    child: Icon(
                      LineIcons.arrowRight,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  )
                ],
              )),
          Padding(padding: EdgeInsets.only(top: context.getHeight(26))),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Baru Saja Ditambahkan",
                    style: TextStyle(
                        fontFamily: "poppins",
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start),
                GestureDetector(
                  onTap: () {
                    widget.onSeeMoreProducts();
                  },
                  child: Row(
                    children: [
                      Text("Lihat lebih",
                          style: TextStyle(
                              fontFamily: "poppins",
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.start),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 12,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
