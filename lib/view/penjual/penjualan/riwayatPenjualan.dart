import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/analisis_penjualan.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';

class riwayatPenjualan extends StatefulWidget {
  const riwayatPenjualan({super.key, required this.tokoId});
  final String tokoId;

  @override
  State<riwayatPenjualan> createState() => _riwayatPenjualanState();
}

class _riwayatPenjualanState extends State<riwayatPenjualan> {
  List<Map<String, dynamic>> allProdukData = [];
  List<Map<String, dynamic>> availableMonths = [];
  Map<String, dynamic>? selectedPeriode;
  bool isLoading = true;
  int totalPenjualanKeseluruhan = 0;
  int totalPesananSelesai = 0;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadAvailableMonths();
    await _loadAllProdukData();
  }

  Future<void> _loadAvailableMonths() async {
    try {
      final response =
          await AnalisisPenjualanService().getAvailableMonths(widget.tokoId);
      setState(() {
        availableMonths = List<Map<String, dynamic>>.from(
            response['data']['availableMonths']);
      });
    } catch (e) {
      print('Error loading available months: $e');
    }
  }

  Future<void> _loadAllProdukData() async {
    setState(() => isLoading = true);

    try {
      final response =
          await AnalisisPenjualanService().getProdukTerjual(widget.tokoId);
      setState(() {
        allProdukData =
            List<Map<String, dynamic>>.from(response['data']['produkTerlaris']);
        totalPenjualanKeseluruhan =
            response['data']['totalPenjualanKeseluruhan'] ?? 0;
        totalPesananSelesai = response['data']['totalPesananSelesai'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading produk data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProdukDataByMonth(int bulan, int tahun) async {
    setState(() => isLoading = true);

    try {
      final response = await AnalisisPenjualanService()
          .getProdukTerjual(widget.tokoId, bulan: bulan, tahun: tahun);
      setState(() {
        allProdukData =
            List<Map<String, dynamic>>.from(response['data']['produkTerlaris']);
        totalPenjualanKeseluruhan =
            response['data']['totalPenjualanKeseluruhan'] ?? 0;
        totalPesananSelesai = response['data']['totalPesananSelesai'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading produk data by month: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    if (selectedPeriode == null) {
      await _loadAllProdukData();
    } else {
      await _loadProdukDataByMonth(
          selectedPeriode!['bulan'], selectedPeriode!['tahun']);
    }
  }

  void _onPeriodeChanged(Map<String, dynamic>? periode) {
    setState(() {
      selectedPeriode = periode;
    });

    if (periode == null) {
      _loadAllProdukData();
    } else {
      _loadProdukDataByMonth(periode['bulan'], periode['tahun']);
    }
  }

  List<Map<String, dynamic>> get chartData {
    if (allProdukData.length <= 5) {
      return allProdukData;
    }

    // Ambil 5 teratas dan gabungkan sisanya
    final top5 = allProdukData.take(5).toList();
    final others = allProdukData.skip(5).toList();

    if (others.isNotEmpty) {
      final totalOthers = others.fold<int>(
          0, (sum, item) => sum + (item['totalPenjualan'] as int));
      final jumlahTerjualOthers = others.fold<int>(
          0, (sum, item) => sum + (item['jumlahTerjual'] as int));

      top5.add({
        'nama': 'Yang Lain',
        'totalPenjualan': totalOthers,
        'jumlahTerjual': jumlahTerjualOthers,
        'gambar': '',
        'satuan': '',
        'harga': 0,
      });
    }

    return top5;
  }

  List<PieChartSectionData> get pieChartSections {
    final data = chartData;
    final total =
        data.fold<int>(0, (sum, item) => sum + (item['totalPenjualan'] as int));

    final colors = [
      const Color(0xFF1E88E5), // Modern blue
      const Color(0xFFE53935), // Modern red
      const Color(0xFF43A047), // Modern green
      const Color(0xFFFF9800), // Modern orange
      const Color(0xFF8E24AA), // Modern purple
      const Color(0xFF757575), // Modern grey
    ];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = (item['totalPenjualan'] as int).toDouble();
      final percentage = total > 0 ? (value / total * 100) : 0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 85,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'poppins',
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Laporan Penjualan",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: "poppins",
                fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Container(
              color: Colors.grey[50],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Memuat data penjualan...",
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Periode
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: _buildFilterSection(),
                    ),
                    SizedBox(height: context.getHeight(20)),

                    // Summary Cards
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      child: _buildSummaryCards(),
                    ),
                    SizedBox(height: context.getHeight(20)),

                    // Pie Chart
                    if (allProdukData.isNotEmpty) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        child: _buildPieChartSection(),
                      ),
                      SizedBox(height: context.getHeight(20)),
                    ],

                    // Product List
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      child: _buildProductList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text("Filter Periode",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButton<Map<String, dynamic>?>(
              hint: Text("Semua Data",
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "poppins",
                      color: Colors.grey[600])),
              value: selectedPeriode,
              underline: Container(),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: [
                DropdownMenuItem<Map<String, dynamic>?>(
                  value: null,
                  child: Text("Semua Data",
                      style: TextStyle(fontFamily: "poppins")),
                ),
                ...availableMonths.map((periode) {
                  return DropdownMenuItem<Map<String, dynamic>?>(
                    value: periode,
                    child: Text(periode['label'],
                        style: TextStyle(fontFamily: "poppins")),
                  );
                }),
              ],
              onChanged: _onPeriodeChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Total Penjualan",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: "poppins",
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Rp ${Formatter.rupiah(totalPenjualanKeseluruhan)}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green,
                  Colors.green.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Total Pesanan",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: "poppins",
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "$totalPesananSelesai",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Distribusi Penjualan Produk",
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final data = chartData;
    final colors = [
      const Color(0xFF1E88E5), // Modern blue
      const Color(0xFFE53935), // Modern red
      const Color(0xFF43A047), // Modern green
      const Color(0xFFFF9800), // Modern orange
      const Color(0xFF8E24AA), // Modern purple
      const Color(0xFF757575), // Modern grey
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colors[index % colors.length].withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[index % colors.length].withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['nama'],
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Detail Produk Terjual",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          allProdukData.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada data penjualan produk",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Data akan muncul setelah ada transaksi",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: "poppins",
                              color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allProdukData.length,
                  itemBuilder: (context, index) {
                    final produk = allProdukData[index];
                    final isLast = index == allProdukData.length - 1;
                    return Container(
                      margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: isLast ? 16 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: produk['gambar'] != null &&
                                    produk['gambar'].isNotEmpty
                                ? Image.network(
                                    produk['gambar'],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image_not_supported_rounded,
                                        color: Colors.grey[500],
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.shopping_bag_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          produk['nama'],
                          style: TextStyle(
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey[800]),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Text(
                                "Terjual: ${produk['jumlahTerjual']} ${produk['satuan']}",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700]),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Harga: Rp ${Formatter.rupiah(produk['harga'])}/${produk['satuan']}",
                              style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 12,
                                  color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                "Rp ${Formatter.rupiah(produk['totalPenjualan'])}",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
