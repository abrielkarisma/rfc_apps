import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class PaymentSuccessPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const PaymentSuccessPage({super.key, required this.data});
  Map<String, dynamic> _processOrderData(Map<String, dynamic> rawData) {
    final detailList = rawData['PesananDetails'] as List;
    final toko = rawData['Toko'];
    final tanggal = DateFormat('dd MMMM HH:mm:ss')
        .format(DateTime.parse(rawData['createdAt']));
    final totalHarga = rawData['totalHarga'];
    final transactionStatus = rawData['MidtransOrder']['transaction_status'];
    final orderStatus = rawData['status'];
    final pesananId = rawData['id'];
    final metodePembayaran = rawData['MidtransOrder']['bank'];

    return {
      'detailList': detailList,
      'toko': toko,
      'tanggal': tanggal,
      'totalHarga': totalHarga,
      'transactionStatus': transactionStatus,
      'orderStatus': orderStatus,
      'pesananId': pesananId,
      'metodePembayaran': metodePembayaran,
    };
  }

  @override
  Widget build(BuildContext context) {
    final processedData = _processOrderData(data);
    final pesananId = processedData["pesananId"];
    final toko = processedData['toko'];
    final metodePembayaran = processedData['metodePembayaran'];
    final tanggal = processedData['tanggal'];
    final totalHarga = processedData['totalHarga'];
    final transactionStatus = processedData['transactionStatus'];
    final orderStatus = processedData['orderStatus'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Proses Pesanan",
            style: TextStyle(
              fontFamily: "poppins",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: context.getHeight(20)),
            SizedBox(height: context.getHeight(20)),
            Container(
              width: context.getWidth(72),
              height: context.getHeight(72),
              child: SvgPicture.asset(
                "assets/images/Success.svg",
              ),
            ),
            Text(
              "Pembayaran Sukses!",
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: context.getHeight(8)),
            Text(
              "Pembayaranmu berhasil dilakukan.",
              style: TextStyle(fontFamily: "poppins", fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(30)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  paymentDetailRow(
                      "Total Harga", "Rp. ${totalHarga.toString()}"),
                  paymentDetailRow("Status Pembayaran", "Success"),
                  Divider(
                    color: Colors.white.withOpacity(0.5),
                    thickness: 1,
                  ),
                  paymentDetailRow(
                    "Pesanan Id",
                    pesananId.toString(),
                  ),
                  paymentDetailRow("Nama Toko", toko['nama']),
                  paymentDetailRow("Metode Pembayaran", metodePembayaran),
                  paymentDetailRow("Tanggal Pembayaran", tanggal),
                ],
              ),
            ),
            SizedBox(height: context.getHeight(30)),
            Spacer(),
            SizedBox(height: context.getHeight(16)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Selesai",
                style: TextStyle(
                  fontFamily: "poppins",
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                fontFamily: "poppins",
                color: Colors.white,
                fontSize: 13,
              )),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "poppins",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                )),
          ),
        ],
      ),
    );
  }
}
