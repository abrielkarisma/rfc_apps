import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/produk.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';

class ProdukCardSeller extends StatelessWidget {
  final Produk produk;

  const ProdukCardSeller({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/detail_produk',
          arguments: produk.id,
        );
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: context.getWidth(170),
                  height: context.getHeight(170),
                  child:
                      ShimmerImage(imageUrl: produk.gambar, fit: BoxFit.cover),
                ),
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
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'Stok: ${produk.stok} ${produk.satuan}',
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: "Inter",
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Rp ${Formatter.rupiah(produk.harga)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
