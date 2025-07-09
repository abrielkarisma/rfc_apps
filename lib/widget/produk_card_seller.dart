import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/produk.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';

class ProdukCardSeller extends StatelessWidget {
  final Produk produk;
  final VoidCallback? onRefresh;

  const ProdukCardSeller({super.key, required this.produk, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = produk.stok == 0;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/detail_produk',
          arguments: produk.id,
        );
        if (result == 'refresh' && onRefresh != null) {
          onRefresh!();
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: context.getWidth(170),
                      height: context.getHeight(170),
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
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'HABIS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
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
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: Text(
                  produk.nama,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: "Inter",
                    color: isOutOfStock ? Colors.grey[600] : Colors.black,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  isOutOfStock
                      ? 'Stok Habis'
                      : 'Stok: ${produk.stok} ${produk.satuan}',
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: "Inter",
                    color: isOutOfStock ? Colors.red : Colors.grey,
                    fontWeight:
                        isOutOfStock ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  isOutOfStock
                      ? 'Tidak Tersedia'
                      : 'Rp ${Formatter.rupiah(produk.harga)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock ? Colors.red : Colors.green,
                    fontFamily: "Inter",
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
