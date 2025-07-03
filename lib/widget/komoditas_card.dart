import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/komoditas.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';

class KomoditasCard extends StatelessWidget {
  final KomoditasData komoditas;
  const KomoditasCard({super.key, required this.komoditas});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail_komoditas',
          arguments: komoditas.id,
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: context.getWidth(143),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: context.getHeight(120),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      ShimmerImage(imageUrl: komoditas.gambar, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  komoditas.nama,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
