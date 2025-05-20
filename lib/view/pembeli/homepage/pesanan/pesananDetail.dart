import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/midtrans.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/midtransView.dart';
import 'package:rfc_apps/widget/badge_status.dart';

class PesananDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PesananDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final detailList = data['PesananDetails'] as List;
    final toko = data['Toko'];
    final tanggal = DateFormat('dd MMMM yyyy HH:mm:ss')
        .format(DateTime.parse(data['createdAt']));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Detail Pesanan",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  fontSize: 16))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tanggal Pembelian",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: "Poppins")),
                Text(tanggal,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500)),
              ],
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Detail Produk",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: "poppins",
                        fontSize: 12)),
                Text(toko['nama'],
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: "poppins")),
              ],
            ),
            const SizedBox(height: 8),
            ...detailList.map((item) {
              final produk = item['Produk'];
              final jumlah = item['jumlah'];
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          produk['gambar'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: context.getWidth(10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(produk['nama'],
                              style: const TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            "$jumlah ${produk['satuan']}",
                            style: const TextStyle(
                                fontFamily: "poppins",
                                fontSize: 8,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "Rp ${NumberFormat('#,###').format(item['jumlah'] * produk['harga'])}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "poppins",
                            fontSize: 10),
                      ),
                    ],
                  ),
                  SizedBox(height: context.getHeight(8)),
                ],
              );
            }),
            Divider(
              color: Colors.black,
              height: 1,
            ),
            SizedBox(height: context.getHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Harga",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: "poppins")),
                Text("Rp ${NumberFormat('#,###').format(data['totalHarga'])}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "poppins",
                        fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Rincian Pembayaran",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: "poppins")),
            SizedBox(height: context.getHeight(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Metode Pembayaran",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: "poppins")),
                Text(
                  "-",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontFamily: "poppins"),
                ), // nanti ganti kalau Midtrans aktif
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status Pesanan",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: "poppins")),
                StatusBadge(
                  status:
                      data['MidtransOrder']['transaction_status'] == "pending"
                          ? 'belum dibayar'
                          : data['status'],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Alamat Pengambilan",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: "poppins")),
            SizedBox(height: context.getHeight(8)),
            Text(toko['nama'],
                style: const TextStyle(
                    fontFamily: "poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            Text(toko['alamat'],
                style: const TextStyle(
                    fontFamily: "poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          onPressed: () async {
            if (data['MidtransOrder']['transaction_status'] == 'pending') {
              try {
                final result = await MidtransService()
                    .createTransactionForPesanan(data["MidtransOrderId"], data['id']);
                final redirectUrl = result['redirect_url'];
                final orderId = result['order_id'];

                if (redirectUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentWebViewPage(
                        paymentUrl: redirectUrl,
                        orderId: orderId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Gagal mendapatkan link pembayaran")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pesanan sudah dibayar")),
              );
            }
          },
          child: Text(
            data['MidtransOrder']['transaction_status'] == "pending"
                ? "Lakukan Pembayaran"
                : "Selesai",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
