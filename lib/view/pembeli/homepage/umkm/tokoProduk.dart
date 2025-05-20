import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/widget/produk_grid.dart';

class ProdukToko extends StatefulWidget {
  const ProdukToko({super.key, required this.idToko});
  final String idToko;
  @override
  State<ProdukToko> createState() => _ProdukTokoState();
}

class _ProdukTokoState extends State<ProdukToko> {
  Key _produkListKey = UniqueKey();
  void initState() {
    super.initState();
    _produkListKey = UniqueKey();
  }

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
          Padding(
            padding: const EdgeInsets.all(32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: context.getWidth(16)),
                  Container(
                    width: 30,
                    height: 30,
                    child: Image(
                      image: AssetImage('assets/images/cartwhite.png'),
                      fit: BoxFit.contain,
                    ),
                  )
                ],
              ),
              SizedBox(height: context.getHeight(50)),
              Expanded(
                  child: ProdukGrid(
                      key: _produkListKey,
                      cardType: "byToko",
                      id: widget.idToko)),
            ]),
          )
        ],
      ),
    );
  }
}
