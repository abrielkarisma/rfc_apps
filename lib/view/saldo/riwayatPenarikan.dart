import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:shimmer/shimmer.dart';

const Color appPrimaryColor = Color(0xFF4CAD73);
const Color appPrimaryColorLight = Color(0xFFE8F5E9);
const Color appPrimaryColorDark = Color(0xFF2E7D32);
const Color appPendingColor = Colors.orangeAccent;
const Color appCompletedColor = appPrimaryColor;
const Color appRejectedColor = Colors.redAccent;

class RiwayatPenarikanPage extends StatefulWidget {
  const RiwayatPenarikanPage({super.key});

  @override
  State<RiwayatPenarikanPage> createState() => _RiwayatPenarikanPageState();
}

class _RiwayatPenarikanPageState extends State<RiwayatPenarikanPage> {
  final SaldoService _saldoService = SaldoService();
  final List<Map<String, dynamic>> _penarikanList = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPenarikanHistory(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPenarikanHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _penarikanList.clear();
      _errorMessage = null;
      setState(() {
        _isLoading = true;
      });
    } else {
      if (_currentPage >= _totalPages || _isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _saldoService.getMyPenarikanSaldoHistory(
          page: _currentPage, limit: 10);
      // Respons service: { message: "...", data: [...penarikan...], currentPage, totalPages, totalItems }
      final List<dynamic> newPenarikan =
          response['data'] as List<dynamic>? ?? [];

      setState(() {
        _penarikanList.addAll(newPenarikan.cast<Map<String, dynamic>>());
        _totalPages = response['totalPages'] as int? ?? 1;
        if (newPenarikan.isNotEmpty) {
          _currentPage++;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().length > 100
            ? 'Terjadi kesalahan pada server.'
            : e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage <= _totalPages) {
      _fetchPenarikanHistory();
    }
  }

  String formatRupiah(dynamic amount) {
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(numericAmount);
  }

  String formatTanggal(String? dateString) {
    if (dateString == null) return 'Tgl tidak tersedia';
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _formatStatusPenarikan(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'processing':
        return 'Sedang Diproses';
      case 'completed':
        return 'Berhasil Ditarik';
      case 'rejected':
        return 'Ditolak';
      case 'failed':
        return 'Gagal';
      default:
        return status ?? 'Status Tidak Diketahui';
    }
  }

  Color _getColorForStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'processing':
        return appPendingColor;
      case 'completed':
        return appCompletedColor;
      case 'rejected':
      case 'failed':
        return appRejectedColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
      case 'failed':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penarikan',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: appPrimaryColor, // Warna baru
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () => _fetchPenarikanHistory(isRefresh: true),
          color: appPrimaryColor, // Warna baru
          child: _buildPenarikanList(),
        ),
      ),
    );
  }

  Widget _buildPenarikanList() {
    if (_isLoading && _penarikanList.isEmpty) {
      return _buildLoadingShimmerList();
    } else if (_errorMessage != null && _penarikanList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.red.shade400, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                onPressed: () => _fetchPenarikanHistory(isRefresh: true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                    foregroundColor: Colors.white), // Warna baru
              )
            ],
          ),
        ),
      );
    } else if (_penarikanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Belum ada riwayat penarikan.',
                style: TextStyle(fontSize: 17, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _penarikanList.length + (_isLoadingMore ? 1 : 0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      itemBuilder: (context, index) {
        if (index == _penarikanList.length) {
          return _buildLoadingMoreIndicator();
        }
        final penarikan = _penarikanList[index];
        final Map<String, dynamic>? rekeningData =
            penarikan['rekening'] as Map<String, dynamic>?;
        final String status = penarikan['status']?.toString() ?? 'unknown';

        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: InkWell(
            onTap: () => _showDetailPenarikanDialog(context, penarikan),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatRupiah(penarikan['jumlahDiminta']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: appPrimaryColorDark), // Warna baru
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorForStatus(status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getIconForStatus(status),
                                color: _getColorForStatus(status), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _formatStatusPenarikan(status),
                              style: TextStyle(
                                  color: _getColorForStatus(status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID Penarikan: ${penarikan['id']?.toString().substring(0, 8) ?? 'N/A'}...', // Tampilkan sebagian ID
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tujuan: ${rekeningData?['namaBank'] ?? '-'} (${rekeningData?['nomorRekening'] ?? '-'})',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  Text(
                    'a.n ${rekeningData?['namaPemilikRekening'] ?? rekeningData?['namaPenerima'] ?? '-'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tanggal Diajukan: ${formatTanggal(penarikan['tanggalRequest']?.toString())}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  if (penarikan['tanggalProses'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Tanggal Diproses: ${formatTanggal(penarikan['tanggalProses']?.toString())}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[350]!,
      highlightColor: Colors.grey[200]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        itemBuilder: (_, __) => Card(
          elevation: 1.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 120, height: 20.0, color: Colors.white),
                      Container(
                          width: 80,
                          height: 16.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(top: 4)),
                    ]),
                const SizedBox(height: 8),
                Container(
                    width: double.infinity, height: 12.0, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 150, height: 12.0, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(color: appPrimaryColor), // Warna baru
      ),
    );
  }

  void _showDetailPenarikanDialog(
      BuildContext context, Map<String, dynamic> penarikan) {
    final Map<String, dynamic>? rekeningData =
        penarikan['rekening'] as Map<String, dynamic>?;
    final String status = penarikan['status']?.toString() ?? 'unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(_getIconForStatus(status),
                  color: _getColorForStatus(status), size: 28),
              const SizedBox(width: 10),
              Text('Detail Penarikan',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                    'ID Penarikan', penarikan['id']?.toString() ?? '-'),
                _buildDetailRow('Status', _formatStatusPenarikan(status),
                    valueColor: _getColorForStatus(status)),
                _buildDetailRow('Tanggal Diajukan',
                    formatTanggal(penarikan['tanggalRequest']?.toString())),
                if (penarikan['tanggalProses'] != null)
                  _buildDetailRow('Tanggal Diproses',
                      formatTanggal(penarikan['tanggalProses']?.toString())),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Jumlah Diminta', formatRupiah(penarikan['jumlahDiminta'])),
                _buildDetailRow(
                    'Biaya Admin', formatRupiah(penarikan['biayaAdmin'])),
                _buildDetailRow('Jumlah Diterima',
                    formatRupiah(penarikan['jumlahDiterima']),
                    valueColor: appPrimaryColorDark, isBold: true),
                const SizedBox(height: 8),
                Text("Rekening Tujuan",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${rekeningData?['namaBank'] ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${rekeningData?['nomorRekening'] ?? '-'}'),
                      Text(
                          'a.n ${rekeningData?['namaPemilikRekening'] ?? rekeningData?['namaPenerima'] ?? '-'}'),
                    ],
                  ),
                ),
                if (penarikan['catatanAdmin'] != null &&
                    penarikan['catatanAdmin'].toString().isNotEmpty)
                  _buildDetailRow('Catatan Admin:',
                      penarikan['catatanAdmin']?.toString() ?? '-'),
                if (penarikan['buktiTransfer'] != null &&
                    penarikan['buktiTransfer'].toString().isNotEmpty)
                  _buildDetailRow('Bukti Transfer:',
                      penarikan['buktiTransfer']?.toString() ?? '-'),
                if (penarikan['referensiBank'] != null &&
                    penarikan['referensiBank'].toString().isNotEmpty)
                  _buildDetailRow('Ref. Bank:',
                      penarikan['referensiBank']?.toString() ?? '-'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup',
                  style: TextStyle(color: appPrimaryColor)), // Warna baru
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600))),
          const SizedBox(width: 8),
          Expanded(
              flex: 3,
              child: Text(": $value",
                  style: TextStyle(
                      color: valueColor ?? Colors.black87,
                      fontWeight:
                          isBold ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }
}
