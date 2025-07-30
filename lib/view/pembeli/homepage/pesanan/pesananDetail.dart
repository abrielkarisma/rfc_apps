import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/midtrans.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
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
    final buktiPesanan = rawData['buktiDiterimaId'] ?? '';

    return {
      'detailList': detailList,
      'toko': toko,
      'tanggal': tanggal,
      'totalHarga': totalHarga,
      'transactionStatus': transactionStatus,
      'orderStatus': orderStatus,
      'buktiPesanan': buktiPesanan,
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
          ToastHelper.showErrorToast(
              context, "Gagal mendapatkan link pembayaran");
        }
      } catch (e) {
        ToastHelper.showErrorToast(context, "Error: $e");
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _showBuktiPesananModal(BuildContext context, String buktiId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bukti Pesanan Diambil",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: PesananService().getBuktiPesanan(buktiId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Gagal memuat bukti pesanan",
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      final buktiData = snapshot.data!['data'];
                      final fotoUrl = buktiData['fotoBukti'];
                      final createdAt = DateTime.parse(buktiData['createdAt']);
                      final formattedDate =
                          DateFormat('dd MMMM yyyy, HH:mm').format(createdAt);

                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fotoUrl,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Gagal memuat gambar",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Pesanan telah diambil",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        "Pada: $formattedDate",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Tidak ada data bukti pesanan",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                      ),
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
    final processedData = _processOrderData(data);
    final detailList = processedData['detailList'];
    final toko = processedData['toko'];
    final tanggal = processedData['tanggal'];
    final totalHarga = processedData['totalHarga'];
    final transactionStatus = processedData['transactionStatus'];
    final orderStatus = processedData['orderStatus'];
    final buktiPesanan = processedData['buktiPesanan'];

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
                    : transactionStatus == "settlement" &&
                            orderStatus == "selesai"
                        ? TextButton(
                            onPressed: () {
                              if (buktiPesanan.isNotEmpty) {
                                _showBuktiPesananModal(context, buktiPesanan);
                              } else {
                                ToastHelper.showInfoToast(
                                    context, "Bukti pesanan tidak tersedia");
                              }
                            },
                            child: Text("Lihat Bukti Pesanan Telah Diambil",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor)))
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
