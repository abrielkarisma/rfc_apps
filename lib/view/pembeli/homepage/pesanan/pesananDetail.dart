import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/midtrans.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/midtransView.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/nota.dart';
import 'package:rfc_apps/widget/badge_status.dart';

class PesananDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PesananDetailPage({super.key, required this.data});

  Map<String, dynamic> _processOrderData(Map<String, dynamic> rawData) {
    final detailList = rawData['PesananDetails'] as List;
    final toko = rawData['Toko'];
    final tanggal = DateFormat('dd MMMM HH:mm:ss')
        .format(DateTime.parse(rawData['createdAt']));
    final totalHarga = rawData['totalHarga'];
    final transactionStatus = rawData['MidtransOrder']['transaction_status'];
    final orderStatus = rawData['status'];

    return {
      'detailList': detailList,
      'toko': toko,
      'tanggal': tanggal,
      'totalHarga': totalHarga,
      'transactionStatus': transactionStatus,
      'orderStatus': orderStatus,
    };
  }

  Future<void> _handlePaymentAction(
      BuildContext context, Map<String, dynamic> data) async {
    if (data['MidtransOrder']['transaction_status'] == 'pending' &&
        data['status'] == 'menunggu') {
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
              content: Text("Gagal mendapatkan link pembayaran"),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final processedData = _processOrderData(data);
    final detailList = processedData['detailList'];
    final toko = processedData['toko'];
    final tanggal = processedData['tanggal'];
    final totalHarga = processedData['totalHarga'];
    final transactionStatus = processedData['transactionStatus'];
    final orderStatus = processedData['orderStatus'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tanggal Pembelian",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "Poppins",
                  ),
                ),
                Text(
                  tanggal,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail Produk",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "poppins",
                    fontSize: 12,
                  ),
                ),
                Text(
                  toko['nama'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: "poppins",
                  ),
                ),
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
                          Text(
                            produk['nama'],
                            style: const TextStyle(
                              fontFamily: "poppins",
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "$jumlah ${produk['satuan']}",
                            style: const TextStyle(
                              fontFamily: "poppins",
                              fontSize: 8,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        "Rp ${NumberFormat('#,###').format(item['jumlah'] * produk['harga'])}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.getHeight(8)),
                ],
              );
            }).toList(),
            const Divider(
              color: Colors.black,
              height: 1,
            ),
            SizedBox(height: context.getHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Harga",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "poppins",
                  ),
                ),
                Text(
                  "Rp ${NumberFormat('#,###').format(totalHarga)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "poppins",
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Rincian Pembayaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: "poppins",
              ),
            ),
            SizedBox(height: context.getHeight(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Metode Pembayaran",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "poppins",
                  ),
                ),
                transactionStatus == "pending"
                    ? Text(
                        "-",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: "poppins",
                        ),
                      )
                    : Text(
                        "${data['MidtransOrder']['bank']}".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: "poppins",
                        ),
                      ),
              ],
            ),
            SizedBox(height: context.getHeight(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status Pesanan",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: "poppins",
                  ),
                ),
                StatusBadge(
                  status:
                      transactionStatus == "pending" && orderStatus == "expired"
                          ? 'expired'
                          : transactionStatus == "pending" &&
                                  orderStatus == "menunggu"
                              ? 'belum dibayar'
                              : orderStatus,
                ),
              ],
            ),
            SizedBox(height: context.getHeight(8)),
            transactionStatus == "pending" && orderStatus == "expired"
                ? Text(
                    "Pesanan telah kadaluarsa, silahkan lakukan pemesanan ulang.",
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  )
                : transactionStatus == "pending" && orderStatus == "menunggu"
                    ? Text(
                        "Silahkan lakukan pembayaran untuk menyelesaikan pesanan.",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PaymentSuccessPage(
                                        data: data,
                                      )));
                        },
                        child: Text("Lihat Bukti Pembayaran",
                            style: TextStyle(
                                fontFamily: "poppins",
                                fontSize: 12,
                                color: Theme.of(context).primaryColor))),
            SizedBox(height: context.getHeight(24)),
            const Text(
              "Alamat Pengambilan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: "poppins",
              ),
            ),
            SizedBox(height: context.getHeight(8)),
            Text(
              toko['nama'],
              style: const TextStyle(
                fontFamily: "poppins",
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              toko['alamat'],
              style: const TextStyle(
                fontFamily: "poppins",
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          onPressed: () => _handlePaymentAction(context, data),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            transactionStatus == "pending" && orderStatus == "menunggu"
                ? "Lakukan Pembayaran"
                : "Selesai",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
