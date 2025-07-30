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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<Map<String, dynamic>> _penarikanList = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _userId = "";

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

  Future<void> _fetchPenarikanHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _penarikanList.clear();
      _errorMessage = null;
      setState(() {
        _isLoading = true;
      });
      await _getUserId();
    } else {
      if (_currentPage >= _totalPages || _isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = _userId.isNotEmpty
          ? await _saldoService.getMyPenarikanSaldoHistoryByIdUser(_userId,
              page: _currentPage, limit: 10)
          : await _saldoService.getMyPenarikanSaldoHistory(
              page: _currentPage, limit: 10);

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
        ToastHelper.showErrorToast(context, _errorMessage!);
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'poppins',
              fontSize: 16,
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: RefreshIndicator(
            onRefresh: () => _fetchPenarikanHistory(isRefresh: true),
            color: appPrimaryColor,
            backgroundColor: Colors.white,
            child: _buildPenarikanList(),
          ),
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
                    foregroundColor: Colors.white),
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
                Icons.history_toggle_off_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada riwayat penarikan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Penarikan yang Anda ajukan akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: _penarikanList.length + (_isLoadingMore ? 1 : 0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      itemBuilder: (context, index) {
        if (index == _penarikanList.length) {
          return _buildLoadingMoreIndicator();
        }
        final penarikan = _penarikanList[index];
        final Map<String, dynamic>? rekeningData =
            penarikan['rekening'] as Map<String, dynamic>?;
        final String status = penarikan['status']?.toString() ?? 'unknown';

        return Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          shadowColor: Colors.grey.withOpacity(0.3),
          child: InkWell(
            onTap: () => _showDetailPenarikanDialog(context, penarikan),
            borderRadius: BorderRadius.circular(16.0),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyFormatter.formatRupiah(
                                    penarikan['jumlahDiminta']),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: appPrimaryColorDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ID: ${penarikan['id']?.toString().substring(0, 8) ?? 'N/A'}...',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getColorForStatus(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _getColorForStatus(status).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getIconForStatus(status),
                                color: _getColorForStatus(status),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatStatusPenarikan(status),
                                style: TextStyle(
                                  color: _getColorForStatus(status),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey.shade300,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: appPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: appPrimaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rekeningData?['namaBank'] ?? '-'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${rekeningData?['nomorRekening'] ?? '-'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                'a.n ${rekeningData?['namaPemilikRekening'] ?? rekeningData?['namaPenerima'] ?? '-'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey.shade500,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diajukan: ${DateFormatter.formatTanggalSingkat(penarikan['tanggalRequest']?.toString())} ${DateFormatter.formatJam(penarikan['tanggalRequest']?.toString())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (penarikan['tanggalProses'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Diproses: ${DateFormatter.formatTanggalSingkat(penarikan['tanggalProses']?.toString())} ${DateFormatter.formatJam(penarikan['tanggalProses']?.toString())}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade400,
                          size: 14,
                        ),
                      ],
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

  Widget _buildLoadingShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 5,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        itemBuilder: (_, __) => Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 140, height: 22.0, color: Colors.white),
                      Container(width: 100, height: 20.0, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(width: 40, height: 40, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: double.infinity,
                                height: 14.0,
                                color: Colors.white),
                            const SizedBox(height: 4),
                            Container(
                                width: 120, height: 12.0, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(width: 200, height: 12.0, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 10,
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appPrimaryColor.withOpacity(0.1),
                  appPrimaryColorLight,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getColorForStatus(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForStatus(status),
                    color: _getColorForStatus(status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Penarikan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _formatStatusPenarikan(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getColorForStatus(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                            'ID Penarikan', penarikan['id']?.toString() ?? '-'),
                        _buildDetailRow(
                            'Status', _formatStatusPenarikan(status),
                            valueColor: _getColorForStatus(status)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                color: Colors.blue.shade600, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Waktu Transaksi',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                            'Tanggal Diajukan',
                            DateFormatter.formatTanggal(
                                penarikan['tanggalRequest']?.toString())),
                        if (penarikan['tanggalProses'] != null)
                          _buildDetailRow(
                              'Tanggal Diproses',
                              DateFormatter.formatTanggal(
                                  penarikan['tanggalProses']?.toString())),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appPrimaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: appPrimaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                            'Jumlah Diminta',
                            CurrencyFormatter.formatRupiah(
                                penarikan['jumlahDiminta'])),
                        _buildDetailRow(
                            'Biaya Admin',
                            CurrencyFormatter.formatRupiah(
                                penarikan['biayaAdmin'])),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: _buildDetailRow(
                              'Jumlah Diterima',
                              CurrencyFormatter.formatRupiah(
                                  penarikan['jumlahDiterima']),
                              valueColor: appPrimaryColorDark,
                              isBold: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance,
                                color: Colors.orange.shade600, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "Rekening Tujuan",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rekeningData?['namaBank'] ?? '-'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${rekeningData?['nomorRekening'] ?? '-'}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'a.n ${rekeningData?['namaPemilikRekening'] ?? rekeningData?['namaPenerima'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (penarikan['catatanAdmin'] != null &&
                      penarikan['catatanAdmin'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.note_alt,
                                    color: Colors.red.shade600, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Catatan Admin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              penarikan['catatanAdmin']?.toString() ?? '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (penarikan['buktiTransfer'] != null &&
                      penarikan['buktiTransfer'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBuktiTransferDialog(
                                context, penarikan['buktiTransfer']);
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text("Lihat Bukti Transfer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextButton(
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              ": $value",
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuktiTransferDialog(BuildContext context, penarikan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appPrimaryColor.withOpacity(0.1),
                  appPrimaryColorLight,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: appPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: appPrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Bukti Transfer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  penarikan,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: appPrimaryColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Gagal memuat gambar bukti transfer',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextButton(
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
