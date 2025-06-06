import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/view/saldo/riwayatPenarikan.dart';
import 'package:rfc_apps/view/saldo/tarikSaldo.dart';
import 'package:shimmer/shimmer.dart';

class SaldoPage extends StatefulWidget {
  const SaldoPage({super.key});

  @override
  State<SaldoPage> createState() => _SaldoPageState();
}

class _SaldoPageState extends State<SaldoPage> {
  final SaldoService _saldoService = SaldoService();
  late Future<Map<String, dynamic>> _saldoFuture;

  @override
  void initState() {
    super.initState();
    _loadSaldo();
  }

  void _loadSaldo() {
    setState(() {
      _saldoFuture = _saldoService.getMySaldo();
    });
  }

  String formatRupiah(dynamic amount) {
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(numericAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saldo Saya',
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            )),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100], // Latar belakang halaman yang lembut
      body: FutureBuilder<Map<String, dynamic>>(
        future: _saldoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        color: Theme.of(context).primaryColor, size: 70),
                    const SizedBox(height: 20),
                    Text(
                      'Oops! Gagal memuat saldo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}'.length > 100
                          ? 'Terjadi kesalahan pada server.'
                          : '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      onPressed: _loadSaldo,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final saldoDataMap = snapshot.data!;
            return _buildSaldoView(saldoDataMap);
          } else {
            return const Center(child: Text('Tidak ada data saldo tersedia.'));
          }
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[350]!, // Warna shimmer lebih gelap sedikit
      highlightColor: Colors.grey[200]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150.0, // Kartu saldo lebih besar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16), // Border radius lebih besar
              ),
            ),
            const SizedBox(height: 30), // Jarak lebih besar
            _buildShimmerActionButton(),
            _buildShimmerActionButton(),
            _buildShimmerActionButton(),
            _buildShimmerActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerActionButton() {
    return Container(
        width: double.infinity,
        height: 55, // Tinggi tombol shimmer
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 12));
  }

  Widget _buildSaldoView(Map<String, dynamic> saldoDataMap) {
    final String saldoTersedia =
        saldoDataMap['saldoTersedia']?.toString() ?? '0.0';
    final Map<String, dynamic>? userDataMap =
        saldoDataMap['user'] as Map<String, dynamic>?;
    final String userName = userDataMap?['nama'] ?? 'Pengguna';

    return RefreshIndicator(
      onRefresh: () async => _loadSaldo(),
      color: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Agar selalu bisa di-scroll untuk refresh
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Color(0xFF93E2B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Tersedia:',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(saldoTersedia),
                    style: const TextStyle(
                      fontSize: 40, // Font lebih besar
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Menu Aksi',
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildActionButton(
              context,
              icon: Icons.receipt_long_rounded,
              label: 'Riwayat Mutasi',
              onPressed: () {
                Navigator.pushNamed(context, '/mutasi_saldo');
              },
              isOutlined: true,
            ),
            _buildActionButton(
              context,
              icon: Icons.output_rounded,
              label: 'Tarik Saldo',
              onPressed: () {
                final double saldoSaatIni = double.tryParse(
                        saldoDataMap['saldoTersedia']?.toString() ?? '0.0') ??
                    0.0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TarikSaldoPage(saldoTersedia: saldoSaatIni)),
                ).then((updated) {
                  if (updated == true) {
                    _loadSaldo();
                  }
                });
              },
              isOutlined: true,
            ),
            _buildActionButton(
              context,
              icon: Icons.history_toggle_off_rounded, // Ikon baru
              label: 'Riwayat Penarikan',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RiwayatPenarikanPage()),
                );
              },
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      bool isOutlined = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: ElevatedButton.icon(
        icon: Icon(icon,
            size: 22,
            color: isOutlined ? Theme.of(context).primaryColor : Colors.white),
        label: Text(label,
            style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                color:
                    isOutlined ? Theme.of(context).primaryColor : Colors.white,
                fontWeight: FontWeight.w500)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined ? Colors.white : Theme.of(context).primaryColor,
          elevation: isOutlined ? 0 : 3,
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 16), // Padding lebih besar
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12.0), // Border radius lebih besar
            side: isOutlined
                ? BorderSide(color: Theme.of(context).primaryColor, width: 1.5)
                : BorderSide.none,
          ),
          alignment: Alignment.centerLeft, // Teks dan ikon rata kiri
        ).copyWith(
          overlayColor: MaterialStateProperty.all(isOutlined
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }
}
