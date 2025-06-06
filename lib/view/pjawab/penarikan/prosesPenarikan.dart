import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/view/saldo/riwayatPenarikan.dart';

// Definisikan warna utama Anda di sini atau dari file tema
const Color appPrimaryColor = Color(0xFF4CAD73);
const Color appPendingColor = Colors.orangeAccent;
const Color appCompletedColor =
    appPrimaryColor; // Bisa juga Colors.green atau shade dari primary
const Color appRejectedColor = Colors.redAccent;

class AdminProsesPenarikanPage extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const AdminProsesPenarikanPage({super.key, required this.requestData});

  @override
  State<AdminProsesPenarikanPage> createState() =>
      _AdminProsesPenarikanPageState();
}

class _AdminProsesPenarikanPageState extends State<AdminProsesPenarikanPage> {
  final SaldoService _saldoService = SaldoService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _catatanAdminController;
  late TextEditingController _buktiTransferController;
  late TextEditingController _referensiBankController;

  bool _isSubmitting = false;
  late String _currentStatus; // Untuk menyimpan status awal

  @override
  void initState() {
    super.initState();
    _catatanAdminController = TextEditingController(
        text: widget.requestData['catatanAdmin']?.toString());
    _buktiTransferController = TextEditingController(
        text: widget.requestData['buktiTransfer']?.toString());
    _referensiBankController = TextEditingController(
        text: widget.requestData['referensiBank']?.toString());
    _currentStatus = widget.requestData['status']?.toString() ?? 'pending';
  }

  @override
  void dispose() {
    _catatanAdminController.dispose();
    _buktiTransferController.dispose();
    _referensiBankController.dispose();
    super.dispose();
  }

  String formatRupiah(dynamic amount) {
    double numericAmount = 0.0;
    if (amount is String)
      numericAmount = double.tryParse(amount) ?? 0.0;
    else if (amount is num) numericAmount = amount.toDouble();
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(numericAmount);
  }

  String formatTanggal(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
          .format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  String _formatStatusDisplay(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'completed':
        return 'Berhasil Ditarik';
      case 'rejected':
        return 'Ditolak';
      default:
        return status ?? 'Tidak Diketahui';
    }
  }

  Color _getColorForStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return appPendingColor;
      case 'completed':
        return appCompletedColor;
      case 'rejected':
        return appRejectedColor;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitProses(String newStatus) async {
    if (_formKey.currentState!.validate()) {
      bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                title: Text('Konfirmasi Proses',
                    style: TextStyle(
                        fontFamily: "poppins",
                        color: newStatus == 'completed'
                            ? appCompletedColor
                            : appRejectedColor)),
                content: Text(
                    'Anda yakin ingin ${newStatus == 'completed' ? 'MENYETUJUI' : 'MENOLAK'} permintaan penarikan ini?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Batal'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: Text(
                        newStatus == 'completed' ? 'Ya, Setujui' : 'Ya, Tolak',
                        style: TextStyle(
                            fontFamily: "poppins",
                            color: newStatus == 'completed'
                                ? appCompletedColor
                                : appRejectedColor)),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirm) return;

      setState(() {
        _isSubmitting = true;
      });

      try {
        await _saldoService.prosesPenarikanSaldo(
          penarikanId: widget.requestData['id'].toString(),
          status: newStatus,
          catatanAdmin: _catatanAdminController.text.trim().isNotEmpty
              ? _catatanAdminController.text.trim()
              : null,
          buktiTransfer: _buktiTransferController.text.trim().isNotEmpty
              ? _buktiTransferController.text.trim()
              : null,
          referensiBank: _referensiBankController.text.trim().isNotEmpty
              ? _referensiBankController.text.trim()
              : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Permintaan penarikan berhasil diubah menjadi "$newStatus".'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memproses: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? userData =
        widget.requestData['user'] as Map<String, dynamic>?;
    final Map<String, dynamic>? rekeningData =
        widget.requestData['rekening'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Proses Penarikan',
            style: TextStyle(
                fontFamily: "poppins",
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: appPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Detail Permintaan'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('ID Permintaan:',
                          widget.requestData['id']?.toString() ?? 'N/A'),
                      _buildInfoRow('Status Saat Ini:',
                          _formatStatusDisplay(_currentStatus),
                          valueColor: _getColorForStatus(_currentStatus),
                          isValueBold: true),
                      _buildInfoRow(
                          'Tanggal Diajukan:',
                          formatTanggal(widget.requestData['tanggalRequest']
                              ?.toString())),
                      if (widget.requestData['tanggalProses'] != null)
                        _buildInfoRow(
                            'Tanggal Diproses:',
                            formatTanggal(widget.requestData['tanggalProses']
                                ?.toString())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Informasi Pengguna'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          'Nama Pengguna:', userData?['name'] ?? 'N/A'),
                      _buildInfoRow('Email:', userData?['email'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Detail Keuangan'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Jumlah Diminta:',
                          formatRupiah(widget.requestData['jumlahDiminta'])),
                      _buildInfoRow('Biaya Admin:',
                          formatRupiah(widget.requestData['biayaAdmin'])),
                      _buildInfoRow('Jumlah Diterima Pengguna:',
                          formatRupiah(widget.requestData['jumlahDiterima']),
                          isValueBold: true, valueColor: appPrimaryColorDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Rekening Tujuan'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          'Nama Bank:', rekeningData?['namaBank'] ?? 'N/A'),
                      _buildInfoRow('Nomor Rekening:',
                          rekeningData?['nomorRekening'] ?? 'N/A'),
                      _buildInfoRow(
                          'Atas Nama:',
                          rekeningData?['namaPemilikRekening'] ??
                              rekeningData?['namaPenerima'] ??
                              'N/A'),
                    ],
                  ),
                ),
              ),
              if (_currentStatus == 'pending') ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Input Admin (Opsional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _catatanAdminController,
                  decoration: InputDecoration(
                    labelText: 'Catatan Admin',
                    hintText: 'Misal: Alasan penolakan, info tambahan',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _buktiTransferController,
                  decoration: InputDecoration(
                    labelText: 'No. Bukti Transfer',
                    hintText: 'Jika transfer manual',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _referensiBankController,
                  decoration: InputDecoration(
                    labelText: 'No. Referensi Bank',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_isSubmitting)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(color: appPrimaryColor),
                ))
              else if (_currentStatus ==
                  'pending')
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('TOLAK'),
                          onPressed: () => _submitProses('rejected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appRejectedColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                                fontFamily: "poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('SETUJUI'),
                          onPressed: () => _submitProses('completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appCompletedColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                                fontFamily: "poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        title,
        style: TextStyle(
            fontFamily: "poppins",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool isValueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, // Lebar label
            child: Text(label,
                style: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.grey.shade600,
                    fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3, // Lebar nilai
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "poppins",
                fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
