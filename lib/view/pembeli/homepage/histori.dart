import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/pesananDetail.dart';
import 'package:rfc_apps/widget/badge_status.dart';

class Histori extends StatefulWidget {
  const Histori({super.key});

  @override
  State<Histori> createState() => _HistoriState();
}

class _HistoriState extends State<Histori> {
  List<dynamic> _pesananList = [];
  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  Future<void> _loadPesanan() async {
    try {
      final data = await PesananService().getPesananUser();
      setState(() {
        _pesananList = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _refreshHistori() async {
    await _loadPesanan();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            left: 20, right: 20, top: context.getHeight(100), bottom: 20),
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          Container(
            width: double.infinity,
            child: Text("Riwayat Pesanan",
                style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.start),
          ),
          SizedBox(height: context.getHeight(20)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshHistori,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
              itemCount: _pesananList.length,
              itemBuilder: (context, index) {
                final pesanan = _pesananList[index];
                final detail = pesanan['PesananDetails'] as List;
                final produkUtama = detail.first['Produk'];
                final midtransOrder = pesanan['MidtransOrder'];
                final tanggal = DateFormat('dd MMMM yyyy')
                    .format(DateTime.parse(pesanan['createdAt']));
                String status;
                if (pesanan['status'] == 'expired') {
                  status = 'expired';
                } else if (midtransOrder != null &&
                    midtransOrder['transaction_status'] == 'pending') {
                  status = 'belum dibayar';
                } else if (pesanan['status'] == 'menunggu') {
                  status = 'menunggu';
                } else if (pesanan['status'] == 'diterima') {
                  status = 'diterima';
                } else if (pesanan['status'] == 'selesai') {
                  status = 'selesai';
                } else {
                  status = pesanan['status'] ?? 'unknown';
                }
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PesananDetailPage(
                              data: pesanan,
                            )),
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: context.getWidth(50),
                                height: context.getHeight(50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        pesanan['Toko']['logoToko']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: context.getWidth(10)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pesanan['Toko']['nama'].length > 14
                                        ? '${pesanan['Toko']['nama'].substring(0, 14)}...'
                                        : pesanan['Toko']['nama'],
                                    style: const TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(tanggal,
                                      style: const TextStyle(
                                          fontFamily: "poppins",
                                          fontSize: 8,
                                          color: Colors.grey)),
                                  const SizedBox(height: 8),
                                ],
                              ),
                              Spacer(),
                              StatusBadge(status: status),
                            ],
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: context.getHeight(20),
                          ),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  produkUtama['gambar'],
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(produkUtama['nama'],
                                      style: const TextStyle(
                                          fontFamily: "poppins",
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    "${detail.first['jumlah']} ${produkUtama['satuan']}",
                                    style: const TextStyle(
                                        fontFamily: "poppins",
                                        fontSize: 8,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: context.getHeight(8)),
                          if (detail.length > 1)
                            Text("+${detail.length - 1} Produk lainnya",
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: "poppins",
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey)),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: [
                                Text(
                                  "Total Belanja",
                                  style: const TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "Rp ${NumberFormat('#,###').format(
                                    pesanan['totalHarga'],
                                  )}",
                                  style: TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D2D2D)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        )]));
  }
}
