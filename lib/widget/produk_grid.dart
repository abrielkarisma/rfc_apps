import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/widget/product_card_umkm.dart';
import 'package:rfc_apps/widget/produk_card_rfc.dart';
import 'package:rfc_apps/widget/produk_card_seller.dart';
import 'package:rfc_apps/model/produk.dart';
import 'package:shimmer/shimmer.dart';

class ProdukGrid extends StatefulWidget {
  const ProdukGrid(
      {super.key,
      required this.cardType,
      required this.id,
      this.searchQuery = '',
      this.onRefresh,
      this.showDeletedProducts = false});
  final String id;
  final String cardType;
  final String searchQuery;
  final VoidCallback? onRefresh;
  final bool showDeletedProducts;

  @override
  State<ProdukGrid> createState() => _ProdukGridState();
}

class _ProdukGridState extends State<ProdukGrid> {
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
      return [];
    }

    // Filter produk berdasarkan isDeleted jika showDeletedProducts = false
    if (!widget.showDeletedProducts) {
      allProducts = allProducts.where((produk) => !produk.isDeleted).toList();
    }

    allProducts.shuffle(Random());

    return allProducts;
  }

  Widget _returnCard(Produk produk) {
    if (index == 0) {
      return ProdukCardSeller(produk: produk, onRefresh: widget.onRefresh);
    } else if (index == 1) {
      return ProdukCardRFC(produk: produk);
    } else if (index == 2) {
      return ProdukCardUMKM(produk: produk);
    } else if (index == 3) {
      return ProdukCardUMKM(produk: produk);
    }

    return Container();
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 143 / 201,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
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
                          width: 100,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 60,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Produk>>(
        key: widget.key, // Gunakan key dari widget untuk memastikan refresh
        future: _selectedProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          print(snapshot.error);
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
                      'Tidak ada produk yang ditemukan.',
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

          List<Produk> produkList = snapshot.data!;
          if (widget.searchQuery.isNotEmpty) {
            produkList = produkList
                .where((item) => item.nama
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase()))
                .toList();
          }

          if (produkList.isEmpty) {
            return const Center(child: Text('Tidak ada produk yang sesuai'));
          }

          return Container(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 143 / 201,
              ),
              itemCount: produkList.length,
              itemBuilder: (context, index) {
                return _returnCard(produkList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
