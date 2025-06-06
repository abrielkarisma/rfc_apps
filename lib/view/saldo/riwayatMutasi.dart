import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:shimmer/shimmer.dart';

class RiwayatMutasiPage extends StatefulWidget {
  const RiwayatMutasiPage({super.key});

  @override
  State<RiwayatMutasiPage> createState() => _RiwayatMutasiPageState();
}

class _RiwayatMutasiPageState extends State<RiwayatMutasiPage> {
  final SaldoService _saldoService = SaldoService();
  List<Map<String, dynamic>> _mutasiList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isFirstLoad = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMutasi(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _currentPage < _totalPages &&
          !_isLoading) {
        _fetchMutasi();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMutasi({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _isFirstLoad = true;
      }
    });

    if (isRefresh) {
      _currentPage = 1;
      _mutasiList = []; 
    }

    try {
      final responseMap = await _saldoService.getMyMutasiSaldo(
          page: _currentPage, limit: 15); 

      final List<dynamic> newMutasiDynamic =
          responseMap['data'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> newMutasi =
          newMutasiDynamic.map((item) => item as Map<String, dynamic>).toList();

      setState(() {
        _mutasiList.addAll(newMutasi);
        _totalPages = responseMap['totalPages'] as int? ?? 1;
        if (newMutasi.isNotEmpty) {
          _currentPage++;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    }
  }

  String formatRupiah(dynamic amount,
      {bool showSymbol = true, bool withSign = false}) {
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: showSymbol ? 'Rp ' : '',
      decimalDigits: 0,
    );

    String formatted = formatCurrency.format(numericAmount.abs());
    if (withSign) {
      return (numericAmount >= 0 ? '+ ' : '- ') + formatted;
    }
    return formatted;
  }

  String formatTanggal(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('EEEE, dd MMM yyyy - HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString; 
    }
  }

  Widget _getTransaksiIcon(String tipeTransaksi, double jumlah) {
    IconData icon;
    Color color;

    bool isKredit = jumlah > 0;

    switch (tipeTransaksi) {
      case 'pendapatan_masuk_penjual':
        icon = Icons.arrow_downward_rounded;
        color = Colors.green.shade600;
        break;
      case 'refund_pesanan_pembeli':
        icon = Icons.replay_circle_filled_rounded;
        color = Colors.blue.shade600;
        break;
      case 'penarikan_dana': 
        icon = Icons.arrow_upward_rounded;
        color = Colors.red.shade600;
        break;
      case 'penarikan_ditolak_dikembalikan': 
        icon = Icons.undo_rounded;
        color = Colors.orange.shade700;
        break;
      default:
        icon = isKredit
            ? Icons.add_circle_outline_rounded
            : Icons.remove_circle_outline_rounded;
        color = isKredit ? Colors.green.shade600 : Colors.red.shade600;
    }
    return Icon(icon, color: color, size: 28);
  }

  String _getTransaksiLabel(String tipeTransaksi) {
    switch (tipeTransaksi) {
      case 'pendapatan_masuk_penjual':
        return 'Pendapatan Toko';
      case 'refund_pesanan_pembeli':
        return 'Refund Pesanan';
      case 'penarikan_dana':
        return 'Penarikan Dana (Berhasil)';
      case 'penarikan_ditolak_dikembalikan':
        return 'Penarikan Ditolak (Dana Kembali)';
      default:
        return tipeTransaksi
            .replaceAll('_', ' ')
            .split(' ')
            .map((str) => str[0].toUpperCase() + str.substring(1))
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Mutasi Saldo',
            style: TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () => _fetchMutasi(isRefresh: true),
        color: Theme.of(context).primaryColor,
        child: _isFirstLoad &&
                _isLoading
            ? _buildMutasiListShimmer()
            : _mutasiList.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _mutasiList.length +
                        (_isLoading && _currentPage <= _totalPages
                            ? 1
                            : 0), 
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    itemBuilder: (context, index) {
                      if (index == _mutasiList.length) {
                        return _buildLoadingIndicator();
                      }
                      final mutasi = _mutasiList[index];
                      final double jumlah = double.tryParse(
                              mutasi['jumlah']?.toString() ?? '0.0') ??
                          0.0;
                      final bool isKredit = jumlah > 0;

                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          leading: CircleAvatar(
                            backgroundColor:
                                (isKredit ? Colors.green : Colors.red)
                                    .withOpacity(0.1),
                            child: _getTransaksiIcon(
                                mutasi['tipeTransaksi'].toString(), jumlah),
                          ),
                          title: Text(
                            _getTransaksiLabel(
                                mutasi['tipeTransaksi'].toString()),
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey.shade800),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                formatTanggal(mutasi['createdAt'].toString()),
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 12,
                                    color: Colors.grey.shade600),
                              ),
                              if (mutasi['keterangan'] != null &&
                                  mutasi['keterangan']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  mutasi['keterangan'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 12.5,
                                      color: Colors.grey.shade700),
                                ),
                              ]
                            ],
                          ),
                          trailing: Text(
                            formatRupiah(jumlah, withSign: true),
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isKredit
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          isThreeLine: (mutasi['keterangan'] != null &&
                              mutasi['keterangan'].toString().isNotEmpty),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildMutasiListShimmer() {
    return ListView.builder(
      itemCount: 7,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.5,
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              leading: CircleAvatar(backgroundColor: Colors.white, radius: 28),
              title: Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.4,
                  color: Colors.white),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.3,
                      color: Colors.white),
                  const SizedBox(height: 4),
                  Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: Colors.white),
                ],
              ),
              trailing: Container(height: 16, width: 60, color: Colors.white),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Riwayat Mutasi',
              style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua transaksi saldo Anda akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 14,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
