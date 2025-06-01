import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/produk.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class ProdukCardRFC extends StatelessWidget {
  final Produk produk;

  const ProdukCardRFC({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/detail_produk_buyer',
          arguments: produk.id,
        );
        if (result != null) {
          ToastHelper.showErrorToast(context, "Produk Tidak Ditemukan");
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: context.getWidth(143),
          height: context.getHeight(201),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: context.getHeight(143),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ShimmerImage(
                            imageUrl: produk.gambar, fit: BoxFit.cover)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: double.infinity,
                    child: Text(
                      produk.nama,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: "Inter",
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: double.infinity,
                    child: Text(
                      '1 ${produk.satuan}',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "Inter",
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Rp ${Formatter.rupiah(produk.harga)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: context.getHeight(8),
                  ),
                ],
              ),
              Positioned(
                bottom: context.getHeight(8),
                right: context.getWidth(8),
                child: Container(
                    child:
                        Image(image: AssetImage('assets/images/cartplus.png'))),
              ),
              Positioned(
                top: context.getHeight(0),
                right: context.getWidth(0),
                child: Container(
                  // color: Colors.red,
                  width: context.getWidth(50),
                  height: context.getHeight(50),
                  child: Image(
                    image: AssetImage(
                      'assets/images/RFC.png',
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
