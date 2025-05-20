import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/widget/produk_list.dart';

class TokoInformation extends StatefulWidget {
  const TokoInformation({super.key, required this.tokoId});
  final String tokoId;
  @override
  State<TokoInformation> createState() => _TokoInformationState();
}

class _TokoInformationState extends State<TokoInformation> {
  String $gambar = "";
  String $nama = "";
  String $deskripsi = "";
  String $alamat = "";
  String $noTelp = "";
  Key _produkListKey = UniqueKey();
  @override
  void initState() {
    super.initState();
    _getDataToko();
    _produkListKey = UniqueKey();
  }

  void _getDataToko() async {
    final response = await tokoService().getTokoById(widget.tokoId);
    if (response != null) {
      setState(() {
        $gambar = response.data[0].logoToko;
        $nama = response.data[0].nama;
        $deskripsi = response.data[0].deskripsi;
        $alamat = response.data[0].alamat;
        $noTelp = response.data[0].phone;
      });
    } else {
      throw Exception('Failed to load toko data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.getHeight(10)),
            SizedBox(
              width: double.infinity,
              height: context.getHeight(500),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: context.getHeight(115)),
                    width: double.infinity,
                    height: context.getHeight(500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: context.getHeight(40)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: context.getWidth(150),
                        height: context.getHeight(150),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 8,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(76),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: ShimmerImage(
                          imageUrl: $gambar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: context.getHeight(200)),
                    width: double.infinity,
                    height: context.getHeight(300),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: context.getHeight(60),
                          child: Center(
                            child: Text(
                              $nama,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: context.getWidth(300),
                            height: context.getHeight(100),
                            child: Text(
                              $deskripsi,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: context.getHeight(8),
                        ),
                        Container(
                          width: context.getWidth(320),
                          height: context.getHeight(120),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  height: context.getHeight(50),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: context.getWidth(50),
                                        height: context.getHeight(50),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.getWidth(16),
                                      ),
                                      Container(
                                        width: context.getWidth(250),
                                        height: context.getHeight(50),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            $alamat,
                                            style: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                                thickness: 1,
                              ),
                              Container(
                                  height: context.getHeight(50),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: context.getWidth(50),
                                        height: context.getHeight(50),
                                        child: Icon(
                                          Icons.phone_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.getWidth(16),
                                      ),
                                      Container(
                                        width: context.getWidth(250),
                                        height: context.getHeight(50),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            $noTelp,
                                            style: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: context.getHeight(20),
            ),
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              height: context.getHeight(400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: context.getHeight(20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Produk yang Baru Saja Ditambahkan",
                          style: TextStyle(
                              fontFamily: "poppins",
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/toko_produk",
                              arguments: widget.tokoId);
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
                  SizedBox(
                    height: context.getHeight(16),
                  ),
                  ProdukCarousel(
                    key: _produkListKey,
                    cardType: "byToko",
                    id: widget.tokoId,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
