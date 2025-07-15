import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/pendapatan.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';

class riwayatPenjualan extends StatefulWidget {
  const riwayatPenjualan({super.key, required this.tokoId});
  final String tokoId;

  @override
  State<riwayatPenjualan> createState() => _riwayatPenjualanState();
}

class _riwayatPenjualanState extends State<riwayatPenjualan> {
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> filteredData = [];
  String? selectedMonth;
  @override
  void initState() {
    super.initState();
    fetchPendapatan();
  }

  Future<void> fetchPendapatan() async {
    final response = await PendapatanService().getPendapatan(widget.tokoId);
    final List rawData = response['data'];

    setState(() {
      allData = List<Map<String, dynamic>>.from(rawData);
      filteredData = allData;
    });
  }

  Future<void> _refreshRiwayat() async {
    await fetchPendapatan();
  }

  void filterByMonth(String? month) {
    if (month == null) return;

    setState(() {
      selectedMonth = month;
      if (month == 'Semua') {
        filteredData = allData;
      } else {
        filteredData = allData.where((e) {
          final date = DateTime.parse(e['createdAt']);
          final formatted = DateFormat('MMMM yyyy').format(date);
          return formatted == month;
        }).toList();
      }
    });
  }

  int get totalPendapatan =>
      filteredData.fold(0, (sum, item) => sum + (item['harga'] as int));

  List<String> get availableMonths {
    final months = allData
        .map((e) {
          final date = DateTime.parse(e['createdAt']);
          return DateFormat('MMMM yyyy').format(date);
        })
        .toSet()
        .toList();

    months.sort((a, b) => b.compareTo(a));
    return ['Semua', ...months];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Pendapatan Toko",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: "poppins",
                fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filter Bulan: ",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w600)),
                DropdownButton<String>(
                  hint: Text("Pilih Bulan",
                      style: TextStyle(fontSize: 16, fontFamily: "poppins")),
                  value: selectedMonth,
                  items: availableMonths.map((bulan) {
                    return DropdownMenuItem(
                      value: bulan,
                      child: Text(bulan),
                    );
                  }).toList(),
                  onChanged: (value) => filterByMonth(value),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    "Total Pendapatan",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: "poppins",
                        color: Colors.black54),
                  ),
                  Text(
                    "Rp ${Formatter.rupiah(totalPendapatan)}",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: "poppins",
                        color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.getHeight(20)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshRiwayat,
                child: filteredData.isEmpty
                    ? Center(child: Text("Tidak ada data"))
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        final jam = DateFormat('HH:mm')
                            .format(DateTime.parse(item['createdAt']));
                        final tanggal = DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(item['createdAt']));
                        return Card(
                          color: Theme.of(context).primaryColor,
                          child: ListTile(
                            title: Text(
                              "+ Rp ${Formatter.rupiah(item['harga'])}",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$tanggal, $jam",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "poppins",
                                      color: Colors.white),
                                ),
                                Text(
                                  "Pesanan Id: ${item['pesananId'].substring(0, 8)}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "poppins",
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onTap: () {
                              Navigator.pushNamed(context, '/detail_pendapatan',
                                  arguments: {
                                    'Id': item['pesananId'],
                                  });
                            },
                          ),
                        );
                      },
                    ),
            )
        )],
        ),
      ),
    );
  }
}
