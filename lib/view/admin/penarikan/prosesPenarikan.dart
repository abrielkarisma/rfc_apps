import 'package:flutter/material.dart';
import 'dart:io';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/utils/date_formatter.dart';
import 'package:rfc_apps/utils/currency_formatter.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

const Color appPrimaryColor = Color(0xFF34A1AF);
const Color appPrimaryColorLight = Color(0xFFE0F7FA);
const Color appPrimaryColorDark = Color(0xFF2A8A96);
const Color appPendingColor = Colors.orangeAccent;
const Color appCompletedColor = appPrimaryColor;
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
  File? _buktiTransferImage;
  late TextEditingController _referensiBankController;
  bool _isSubmitting = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _catatanAdminController = TextEditingController(
        text: widget.requestData['catatanAdmin']?.toString());
    _referensiBankController = TextEditingController(
        text: widget.requestData['referensiBank']?.toString());
    _currentStatus = widget.requestData['status']?.toString() ?? 'pending';
  }

  @override
  void dispose() {
    _catatanAdminController.dispose();
    _referensiBankController.dispose();
    super.dispose();
  }

  Future<void> _pickBuktiTransfer() async {
    ImagePickerHelper.showImageSourceOptions(
      context,
      onImageSelected: (File image) {
        setState(() {
          _buktiTransferImage = image;
        });
      },
      shouldCrop: false,
    );
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
    if (newStatus == 'rejected' &&
        _catatanAdminController.text.trim().isEmpty) {
      ToastHelper.showInfoToast(context, "Harap isi Catatan");
      return;
    }
    if (_formKey.currentState!.validate()) {
      bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white,
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (newStatus == 'completed'
                                ? appCompletedColor
                                : appRejectedColor)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        newStatus == 'completed'
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: newStatus == 'completed'
                            ? appCompletedColor
                            : appRejectedColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Konfirmasi Proses',
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: newStatus == 'completed'
                                ? appCompletedColor
                                : appRejectedColor)),
                  ],
                ),
                content: Text(
                    'Anda yakin ingin ${newStatus == 'completed' ? 'MENYETUJUI' : 'MENOLAK'} permintaan penarikan ini?',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: Colors.grey[700],
                    )),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Batal',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.grey,
                        )),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  ElevatedButton(
                    child: Text(
                        newStatus == 'completed' ? 'Ya, Setujui' : 'Ya, Tolak',
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: newStatus == 'completed'
                          ? appCompletedColor
                          : appRejectedColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
        if (newStatus == 'completed' && _buktiTransferImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Silakan unggah bukti transfer terlebih dahulu'),
                backgroundColor: Colors.red),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        String? buktiTransferUrl;
        if (_buktiTransferImage != null) {
          final uploadResult = await CloudinaryService()
              .getUploadUrl(File(_buktiTransferImage!.path));
          buktiTransferUrl = uploadResult['url'];
        }
        await _saldoService.prosesPenarikanSaldo(
          penarikanId: widget.requestData['id'].toString(),
          status: newStatus,
          catatanAdmin: _catatanAdminController.text.trim().isNotEmpty
              ? _catatanAdminController.text.trim()
              : null,
          buktiTransfer: buktiTransferUrl,
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
        title: const Text('Proses Penarikan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 18,
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
              const Color(0xFF34A1AF).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Detail Permintaan'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoRow('ID Permintaan:',
                            widget.requestData['id']?.toString() ?? 'N/A'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Status Saat Ini:',
                            _formatStatusDisplay(_currentStatus),
                            valueColor: _getColorForStatus(_currentStatus),
                            isValueBold: true),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            'Tanggal Diajukan:',
                            DateFormatter.formatTanggal(widget
                                .requestData['tanggalRequest']
                                ?.toString())),
                        if (widget.requestData['tanggalProses'] != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              'Tanggal Diproses:',
                              DateFormatter.formatTanggal(widget
                                  .requestData['tanggalProses']
                                  ?.toString())),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Informasi Pengguna'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'Nama Pengguna:', userData?['name'] ?? 'N/A'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Email:', userData?['email'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Detail Keuangan'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'Jumlah Diminta:',
                            CurrencyFormatter.formatRupiah(
                                widget.requestData['jumlahDiminta'])),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            'Biaya Admin:',
                            CurrencyFormatter.formatRupiah(
                                widget.requestData['biayaAdmin'])),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: appPrimaryColorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: appPrimaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: _buildInfoRow(
                              'Jumlah Diterima Pengguna:',
                              CurrencyFormatter.formatRupiah(
                                  widget.requestData['jumlahDiterima']),
                              isValueBold: true,
                              valueColor: appPrimaryColorDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Rekening Tujuan'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            'Nama Bank:', rekeningData?['namaBank'] ?? 'N/A'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Nomor Rekening:',
                            rekeningData?['nomorRekening'] ?? 'N/A'),
                        const SizedBox(height: 12),
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
                  _buildSectionTitle('Input Admin'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Admin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _catatanAdminController,
                            decoration: InputDecoration(
                              hintText:
                                  'Misal: Alasan penolakan, info tambahan...',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: appPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Bukti Transfer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickBuktiTransfer,
                            child: Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _buktiTransferImage == null
                                      ? Colors.grey.shade300
                                      : appPrimaryColor,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _buktiTransferImage == null
                                    ? Colors.grey.shade50
                                    : Colors.white,
                              ),
                              child: _buktiTransferImage == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: appPrimaryColorLight,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 40,
                                            color: appPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Tap untuk mengunggah bukti transfer',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            _buktiTransferImage!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: _pickBuktiTransfer,
                                              padding: const EdgeInsets.all(8),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_isSubmitting)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: appPrimaryColor,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Memproses permintaan...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_currentStatus == 'pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  appRejectedColor,
                                  appRejectedColor.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: appRejectedColor.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel_outlined, size: 20),
                              label: const Text(
                                'TOLAK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () => _submitProses('rejected'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  appPrimaryColor,
                                  appPrimaryColorDark,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: appPrimaryColor.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 20),
                              label: const Text(
                                'SETUJUI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () => _submitProses('completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: appPrimaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool isValueBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isValueBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Poppins',
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
