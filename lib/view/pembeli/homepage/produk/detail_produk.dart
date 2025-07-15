import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/keranjang.dart';
import 'package:rfc_apps/service/keranjang.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/pembeli/homepage/homepage.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/prosesPesanan.dart';
import 'package:rfc_apps/widget/produk_list.dart';
import 'package:rfc_apps/widget/quantityCounter.dart';

class DetailProdukBuyer extends StatefulWidget {
  const DetailProdukBuyer({super.key, required this.idProduk});
  final String idProduk;

  @override
  State<DetailProdukBuyer> createState() => _DetailProdukBuyerState();
}

class _DetailProdukBuyerState extends State<DetailProdukBuyer> {
  String idProduk = "";
  String gambarProduk = "";
  String namaProduk = "";
  String deskripsiProduk = "";
  String hargaProduk = "";
  String kategoriProduk = "";
  String stokProduk = "0"; 
  String satuanProduk = "";
  int jumlahProduk = 1;
  Key _produkListKey = UniqueKey();

  void _updateQuantity(int newQuantity) {
    jumlahProduk = newQuantity;
  }

  int _getStokValue() {
    if (stokProduk.isEmpty) return 0;
    return int.tryParse(stokProduk) ?? 0;
  }

  void initState() {
    super.initState();
    _getDetailProduk();
    _produkListKey = UniqueKey();
  }

  Future<void> _getDetailProduk() async {
    final response = await ProdukService().getProdukById(widget.idProduk);
    if (response.message == "Successfully retrieved produk data") {
      setState(() {
        idProduk = response.data[0].id;
        gambarProduk = response.data[0].gambar;
        namaProduk = response.data[0].nama;
        deskripsiProduk = response.data[0].deskripsi;
        hargaProduk = response.data[0].harga.toString();
        stokProduk = response.data[0].stok.toString();
        satuanProduk = response.data[0].satuan;
        if (satuanProduk == "gr") {
          jumlahProduk = 100;
        }
      });
    } else {
      ToastHelper.showErrorToast(context, 'Gagal mendapatkan detail produk');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Rooftop Farming Center.",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontFamily: "Monserrat_Alternates",
                  fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/images/cart_black.svg',
                width: 24,
                height: 24,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/keranjang");
              },
            ),
          ],
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  width: double.infinity,
                  height: context.getHeight(400),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: context.getWidth(300),
                      height: context.getHeight(300),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ColorFiltered(
                              colorFilter: _getStokValue() == 0
                                  ? ColorFilter.mode(
                                      Colors.grey.withOpacity(0.6),
                                      BlendMode.saturation,
                                    )
                                  : ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.multiply,
                                    ),
                              child: ShimmerImage(
                                imageUrl: gambarProduk,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (_getStokValue() == 0)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black.withOpacity(0.4),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'STOK HABIS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Inter",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: context.getHeight(65),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: context.getWidth(300),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text(
                                "Rp.  $hargaProduk / $satuanProduk",
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(
                                "$namaProduk",
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: context.getWidth(60),
                        child: _getStokValue() == 0
                            ? Column(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  Text(
                                    "Habis",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        color: Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : Text(
                                "Stok : $stokProduk",
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: context.getHeight(8),
                ),
                Container(
                  width: double.infinity,
                  height: context.getHeight(50),
                  child: Text(
                    "$deskripsiProduk",
                    style: TextStyle(
                        fontFamily: "Inter",
                        color: Colors.black45,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: context.getHeight(8),
                ),
                Column(
                  children: [
                    
                    if (_getStokValue() > 0)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 12),
                        child: QuantityCounter(
                          satuan: satuanProduk,
                          stok: stokProduk,
                          onQuantityChanged: _updateQuantity,
                        ),
                      ),

                    
                    Row(
                      children: [
                        
                        if (_getStokValue() > 0)
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/cart_white.svg',
                                width: 20,
                                height: 20,
                              ),
                              onPressed: () async {
                                _addToKeranjang();
                              },
                            ),
                          ),

                        
                        if (_getStokValue() > 0) SizedBox(width: 12),

                        
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: _getStokValue() == 0
                                  ? Colors.grey
                                  : Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text(
                              _getStokValue() == 0
                                  ? 'Stok Habis'
                                  : 'Beli Sekarang',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            onPressed: _getStokValue() == 0
                                ? null
                                : () async {
                                    _beliSekarang();
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: context.getHeight(8),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Baru Saja Ditambahkan",
                          style: TextStyle(
                              fontFamily: "poppins",
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Homepage(
                                        initialIndex: 2,
                                      )));
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
                ),
                SizedBox(
                  height: context.getHeight(8),
                ),
                Container(
                    child: ProdukCarousel(
                  key: _produkListKey,
                  cardType: "rfc",
                  id: "",
                )),
              ]),
            )));
  }

  Future<void> _addToKeranjang() async {
    final keranjangResponse =
        await KeranjangService().createKeranjang(widget.idProduk, jumlahProduk);
    if (keranjangResponse['message'] == "Successfully added to cart") {
      ToastHelper.showSuccessToast(
          context, 'Produk berhasil ditambahkan ke keranjang');
    } else if (keranjangResponse['message'] ==
        "Cart quantity updated successfully") {
      ToastHelper.showSuccessToast(
          context, 'Produk berhasil ditambahkan ke keranjang');
    } else {
      ToastHelper.showErrorToast(
          context, 'Gagal menambahkan produk ke keranjang');
    }
  }

  Future<void> _beliSekarang() async {
    try {
      
      final stockResponse =
          await ProdukService().getProdukStok(widget.idProduk);
      final int stok = stockResponse['data']['stok'];
      if (jumlahProduk > stok) {
        ToastHelper.showErrorToast(
            context, "Jumlah melebihi stok yang tersedia: $stok");
        return;
      }

      
      final originalCartItems = await KeranjangService().getAllKeranjang();
      final originalItem = originalCartItems
          .where((item) => item.produk.id == widget.idProduk)
          .firstOrNull;

      
      await KeranjangService().createKeranjang(widget.idProduk, jumlahProduk);

      
      final tempCartItems = await KeranjangService().getAllKeranjang();
      final tempItem = tempCartItems
          .where((item) => item.produk.id == widget.idProduk)
          .firstOrNull;

      if (tempItem == null) {
        ToastHelper.showErrorToast(
            context, 'Produk tidak ditemukan di keranjang');
        return;
      }

      
      final purchaseItem = CartItem(
        id: tempItem.id,
        jumlah: jumlahProduk,
        produk: tempItem.produk,
      );

      
      if (originalItem != null) {
        
        await KeranjangService()
            .updateKeranjang(tempItem.id, originalItem.jumlah);
      } else {
        
        await KeranjangService().deleteKeranjang(tempItem.id);
      }

      
      final callback = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProsesPesananPage(items: [purchaseItem]),
        ),
      );

      if (callback == "refresh") {
        
        _getDetailProduk();
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, "Gagal memproses pesanan: $e");
    }
  }
}
