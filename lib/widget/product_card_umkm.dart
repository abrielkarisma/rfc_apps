import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/produk.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class ProdukCardUMKM extends StatelessWidget {
  final Produk produk;

  const ProdukCardUMKM({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = produk.stok == 0;

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
        color: isOutOfStock ? Colors.grey[200] : Colors.white,
        elevation: isOutOfStock ? 2 : 4,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: isOutOfStock ? Colors.grey[400]! : Colors.grey,
              width: 0.5),
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
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ColorFiltered(
                              colorFilter: isOutOfStock
                                  ? ColorFilter.mode(
                                      Colors.grey.withOpacity(0.6),
                                      BlendMode.saturation,
                                    )
                                  : ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.multiply,
                                    ),
                              child: ShimmerImage(
                                  imageUrl: produk.gambar, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        if (isOutOfStock)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withOpacity(0.3),
                              ),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'HABIS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                        color: isOutOfStock ? Colors.grey[600] : Colors.black,
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
                      isOutOfStock
                          ? 'Stok Habis'
                          : 'Rp ${Formatter.rupiah(produk.harga)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                        color: isOutOfStock ? Colors.red : Colors.black,
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
                    child: Opacity(
                        opacity: isOutOfStock ? 0.3 : 1.0,
                        child: Image(
                            image: AssetImage('assets/images/cartplus.png')))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
