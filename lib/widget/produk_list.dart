// filepath: d:\flutter\project\rfc_apps\lib\widget\produk_list.dart
import 'package:flutter/material.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/widget/produk_card_seller.dart';
import 'package:rfc_apps/model/produk.dart';

class ProdukList extends StatelessWidget {
  const ProdukList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Produk>>(
        future: ProdukService().getProdukByUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk tersedia'));
          }

          return Container(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 143 / 201,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ProdukCardSeller(produk: snapshot.data![index]);
              },
            ),
          );
        },
      ),
    );
  }
}
