import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class Pendapatan extends StatefulWidget {
  const Pendapatan({super.key, required this.Id});
  final String Id;

  @override
  State<Pendapatan> createState() => _PendapatanState();
}

class _PendapatanState extends State<Pendapatan> {
  Map<String, dynamic>? pesananData;

  @override
  void initState() {
    super.initState();
    fetchPendapatanDetail();
  }

  Future<void> fetchPendapatanDetail() async {
    final response = await PesananService().getPendapatanByPesananId(widget.Id);
    if (response['message'] == "Berhasil mengambil detail pesanan") {
      setState(() {
        pesananData = response['data'];
      });
    } else {
      ToastHelper.showErrorToast(
        context,
        response['message'] ?? 'Gagal mengambil detail pendapatan',
      );
    }
  }

  String formatTanggal(String tanggalIso) {
    final dateTime = DateTime.parse(tanggalIso).toLocal();
    return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
  }

  List<Widget> buildProdukList(List<dynamic> pesananDetails) {
    return pesananDetails.map<Widget>((detail) {
      final produk = detail['Produk'];
      return _buildProdukRow(
        produk['gambar'],
        produk['nama'],
        "${detail['jumlah']} ${produk['satuan']}",
        "Rp ${produk['harga']}",
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pendapatan',
            style: TextStyle(
              fontFamily: "poppins",
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: pesananData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSectionCard(
                            title: 'Informasi Pesanan',
                            children: [
                              _buildInfoRow(
                                  'ID Pesanan',
                                  pesananData!['id']
                                      .toString()
                                      .substring(0, 8)),
                              ...buildProdukList(
                                  pesananData!['PesananDetails']),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            title: 'Informasi Pembayaran',
                            children: [
                              _buildInfoRow(
                                'Tanggal',
                                formatTanggal(pesananData!['MidtransOrder']
                                    ['transaction_time']),
                              ),
                              _buildInfoRow(
                                  'Metode Pembayaran',
                                  pesananData!['MidtransOrder']
                                      ['payment_type']),
                              _buildInfoRow('Total Pembayaran',
                                  "Rp ${pesananData!['totalHarga'].toString()}"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            title: 'Informasi Pembeli',
                            children: [
                              _buildInfoRow(
                                  'Nama', pesananData!['User']['name']),
                              _buildInfoRow(
                                  'Email', pesananData!['User']['email']),
                              _buildInfoRow('Nomor Telepon',
                                  pesananData!['User']['phone']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ));
  }

  Widget _buildSectionCard({String? title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          if (title != null) const Divider(height: 10, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukRow(
      String Gambar, String Nama, String Jumlah, String Harga) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
                shape: BoxShape.rectangle,
              ),
              child: Image.network(
                Gambar,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              Nama,
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Jumlah,
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(Harga,
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                )),
          ],
        ));
  }
}
