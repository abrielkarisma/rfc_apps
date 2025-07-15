import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/keranjang.dart';
import 'package:rfc_apps/service/keranjang.dart';
import 'package:rfc_apps/service/midtrans.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/midtransView.dart';

class ProsesPesananPage extends StatefulWidget {
  final List<CartItem> items;

  const ProsesPesananPage({super.key, required this.items});

  @override
  State<ProsesPesananPage> createState() => _ProsesPesananPageState();
}

String orderId = "";

class _ProsesPesananPageState extends State<ProsesPesananPage> {
  int get total => widget.items
      .fold(0, (sum, item) => sum + item.jumlah * item.produk.harga);

  @override
  Widget build(BuildContext context) {
    final toko = widget.items.first.produk.toko;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Proses Pesanan",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "poppins",
              fontSize: 16,
              color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, "refresh");
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Detail Produk",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: "poppins")),
                  Text(toko.nama,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: "poppins")),
                ],
              ),
              const SizedBox(height: 12),
              ...widget.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(item.produk.gambar,
                            width: 40, height: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.produk.nama,
                                  style: const TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              Text("${item.jumlah} ${item.produk.satuan}",
                                  style: const TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(
                          "Rp. ${Formatter.rupiah(item.jumlah * item.produk.harga)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "poppins",
                              fontSize: 10),
                        ),
                      ],
                    ),
                  )),
              const Divider(
                color: Colors.black,
                height: 1,
              ),
              SizedBox(height: context.getHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Harga",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: "poppins")),
                  Text("Rp. ${Formatter.rupiah(total)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                          fontSize: 10)),
                ],
              ),
              SizedBox(height: context.getHeight(30)),
              const Text("Alamat Pengambilan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                      fontSize: 12)),
              SizedBox(height: context.getHeight(10)),
              Text(
                toko.alamat,
                style: const TextStyle(
                  fontFamily: "poppins",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: context.getHeight(30)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          onPressed: () {
            _handlePesanan();
            
          },
          
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size.fromHeight(context.getHeight(60)),
          ),
          child: const Text(
            "Bayar",
            style: TextStyle(
              fontFamily: "poppins",
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePesanan() async {
    final generateOrderId =
        "RFC_Order_${DateTime.now().millisecondsSinceEpoch.toString()}";
    try {
      final response =
          await PesananService().createPesanan(generateOrderId, widget.items);
      if (response['message'] == "Pesanan berhasil dibuat") {
        for (var item in widget.items) {
          await KeranjangService().deleteKeranjang(item.id);
        }
        final response = await MidtransService()
            .createTransaction(generateOrderId, widget.items);
        setState(() {
          orderId = response['order_id'];
        });
        final String? redirectUrl = response['redirect_url'];

        if (redirectUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PaymentWebViewPage(paymentUrl: redirectUrl, orderId: orderId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal membuat transaksi')));
        }
      } else {
        ToastHelper.showErrorToast(
          context,
          "Pesanan gagal dibuat",
        );
      }
    } catch (e) {
      ToastHelper.showErrorToast(
        context,
        "Terjadi kesalahan saat membuat pesanan : $e",
      );
    }
  }
}
