import 'package:flutter/material.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/utils/date_formatter.dart';
import 'package:rfc_apps/utils/currency_formatter.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Color appPrimaryColor = Color(0xFF4CAD73);
const Color appPrimaryColorLight = Color(0xFFE8F5E9);
const Color appPrimaryColorDark = Color(0xFF2E7D32);

class RiwayatMutasiPage extends StatefulWidget {
  const RiwayatMutasiPage({super.key});

  @override
  State<RiwayatMutasiPage> createState() => _RiwayatMutasiPageState();
}

class _RiwayatMutasiPageState extends State<RiwayatMutasiPage> {
  final SaldoService _saldoService = SaldoService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _mutasiList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isFirstLoad = true;
  final ScrollController _scrollController = ScrollController();
  String _userId = "";

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

  Future<void> _getUserId() async {
    try {
      final id = await _storage.read(key: "id");
      setState(() {
        _userId = id ?? "";
      });
    } catch (e) {
      print("Error getting user ID: $e");
    }
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
      await _getUserId();
    }

    try {
      final responseMap = _userId.isNotEmpty
          ? await _saldoService.getMyMutasiSaldoByIdUser(_userId,
              page: _currentPage, limit: 15)
          : await _saldoService.getMyMutasiSaldo(page: _currentPage, limit: 15);

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
        ToastHelper.showErrorToast(
            context, 'Gagal memuat riwayat: ${e.toString()}');
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
    return Icon(icon, color: color, size: 24);
  }

  Color _getIconBackgroundColor(String tipeTransaksi, double jumlah) {
    bool isKredit = jumlah > 0;

    switch (tipeTransaksi) {
      case 'pendapatan_masuk_penjual':
        return Colors.green.shade100;
      case 'refund_pesanan_pembeli':
        return Colors.blue.shade100;
      case 'penarikan_dana':
        return Colors.red.shade100;
      case 'penarikan_ditolak_dikembalikan':
        return Colors.orange.shade100;
      default:
        return isKredit ? Colors.green.shade100 : Colors.red.shade100;
    }
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
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
              fontSize: 16,
              color: Colors.white,
            )),
        backgroundColor: appPrimaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                appPrimaryColor,
                appPrimaryColorDark,
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => _fetchMutasi(isRefresh: true),
          color: appPrimaryColor,
          backgroundColor: Colors.white,
          child: _isFirstLoad && _isLoading
              ? _buildMutasiListShimmer()
              : _mutasiList.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: _mutasiList.length +
                          (_isLoading && _currentPage <= _totalPages ? 1 : 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 16.0),
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
                          elevation: 3.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          shadowColor: Colors.grey.withOpacity(0.3),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getIconBackgroundColor(
                                          mutasi['tipeTransaksi'].toString(),
                                          jumlah),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: _getTransaksiIcon(
                                        mutasi['tipeTransaksi'].toString(),
                                        jumlah),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getTransaksiLabel(
                                              mutasi['tipeTransaksi']
                                                  .toString()),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              color: Colors.grey.shade500,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${DateFormatter.formatTanggalSingkat(mutasi['createdAt']?.toString())} ${DateFormatter.formatJam(mutasi['createdAt']?.toString())}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (mutasi['keterangan'] != null &&
                                            mutasi['keterangan']
                                                .toString()
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              mutasi['keterangan'].toString(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isKredit
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isKredit
                                                ? Colors.green.shade200
                                                : Colors.red.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          CurrencyFormatter
                                              .formatRupiahWithSign(jumlah),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isKredit
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildMutasiListShimmer() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 200,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 80,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: appPrimaryColor,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Memuat lebih banyak...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Riwayat Mutasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua transaksi saldo Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
