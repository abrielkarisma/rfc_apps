import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/widget/product_card_umkm.dart';
import 'package:rfc_apps/widget/produk_card_rfc.dart';
import 'package:rfc_apps/widget/produk_card_seller.dart';
import 'package:rfc_apps/model/produk.dart';
import 'package:shimmer/shimmer.dart';

class ProdukCarousel extends StatefulWidget {
  const ProdukCarousel({super.key, required this.cardType, required this.id});
  final String id;
  final String cardType;

  @override
  State<ProdukCarousel> createState() => _ProdukCarouselState();
}

class _ProdukCarouselState extends State<ProdukCarousel> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    _produkTypePicker();
  }

  void _produkTypePicker() {
    if (widget.cardType == 'kelola') {
      setState(() {
        index = 0;
      });
    } else if (widget.cardType == 'rfc') {
      setState(() {
        index = 1;
      });
    } else if (widget.cardType == 'umkm') {
      setState(() {
        index = 2;
      });
    } else if (widget.cardType == 'byToko') {
      setState(() {
        index = 3;
      });
    }
  }

  Future<List<Produk>> _selectedProduk() async {
    List<Produk> allProducts;
    if (index == 0) {
      allProducts = await ProdukService().getProdukByUserId(widget.id);
    } else if (index == 1) {
      allProducts = await ProdukService().getRFCProduk();
    } else if (index == 2) {
      allProducts = await ProdukService().getUMKMProduk();
    } else if (index == 3) {
      allProducts = await ProdukService().getProdukByTokoId(widget.id);
    } else {
      allProducts = [];
    }

    allProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allProducts.take(5).toList();
  }

  Widget _returnCard(Produk produk) {
    if (index == 0) {
      return ProdukCardSeller(produk: produk);
    } else if (index == 1) {
      return ProdukCardRFC(produk: produk);
    } else if (index == 2) {
      return ProdukCardUMKM(produk: produk);
    } else if (index == 3) {
      return ProdukCardUMKM(produk: produk);
    }
    return Container();
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return SizedBox(
      height: context.getHeight(210),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(right: 20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: 80,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: 50,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produk>>(
      future: _selectedProduk(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(context);
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 69,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Tidak ada produk yang ditemukan. Silakan coba lagi nanti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk tersedia'));
        }

        return SizedBox(
          height: context.getHeight(210),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 16),
                child: _returnCard(snapshot.data![index]),
              );
            },
          ),
        );
      },
    );
  }
}
