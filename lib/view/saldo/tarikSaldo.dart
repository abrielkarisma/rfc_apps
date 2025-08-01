import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rfc_apps/service/rekening.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Color primaryColor = Color(0xFF4CAD73);
const Color primaryColorLight = Color(0xFFB3FFD2);
const Color primaryColorDark = Color(0xFF2B523B);
const Color primaryColorText = Color(0xFF122219);

class TarikSaldoPage extends StatefulWidget {
  final double saldoTersedia;

  const TarikSaldoPage({super.key, required this.saldoTersedia});

  @override
  State<TarikSaldoPage> createState() => _TarikSaldoPageState();
}

class _TarikSaldoPageState extends State<TarikSaldoPage> {
  final SaldoService _saldoService = SaldoService();
  final rekeningService _rekeningService = rekeningService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();

  Map<String, dynamic>? _rekeningAktif;
  bool _isLoadingRekening = true;
  String? _rekeningErrorMessage;
  String _userId = "";

  bool _isSubmitting = false;

  final double _biayaAdmin = 2500;
  final double _minimumPenarikan = 20000;
  double _jumlahDiterima = 0;

  @override
  void initState() {
    super.initState();
    _fetchRekeningAktif();
    _jumlahController.addListener(_updateJumlahDiterima);
  }

  @override
  void dispose() {
    _jumlahController.removeListener(_updateJumlahDiterima);
    _jumlahController.dispose();
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

  Future<void> _fetchRekeningAktif() async {
    setState(() {
      _isLoadingRekening = true;
      _rekeningErrorMessage = null;
    });
    await _getUserId();

    try {
      final rekening = _userId.isNotEmpty
          ? await _rekeningService.getRekeningByIdUser(_userId)
          : await _rekeningService.getRekeningBytoken();

      setState(() {
        _rekeningAktif = rekening;
      });
    } catch (e) {
      setState(() {
        _rekeningErrorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingRekening = false;
      });
    }
  }

  void _updateJumlahDiterima() {
    final double jumlahDiminta =
        double.tryParse(_jumlahController.text.replaceAll('.', '')) ?? 0;
    setState(() {
      if (jumlahDiminta > 0) {
        _jumlahDiterima = jumlahDiminta - _biayaAdmin;
        if (_jumlahDiterima < 0) _jumlahDiterima = 0;
      } else {
        _jumlahDiterima = 0;
      }
    });
  }

  String formatRupiah(double amount, {bool includeSymbol = true}) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: includeSymbol ? 'Rp ' : '',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  Future<void> _submitPenarikan() async {
    if (_formKey.currentState!.validate()) {
      if (_rekeningAktif == null) {
        ToastHelper.showErrorToast(
            context, 'Tidak ada rekening bank tujuan yang aktif.');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final jumlahDiminta =
            double.parse(_jumlahController.text.replaceAll('.', ''));

        await (_userId.isNotEmpty
            ? _saldoService.createPenarikanSaldoByIdUser(_userId,
                jumlahDiminta: jumlahDiminta)
            : _saldoService.createPenarikanSaldo(jumlahDiminta: jumlahDiminta));

        ToastHelper.showSuccessToast(context,
            'Permintaan penarikan sejumlah ${formatRupiah(jumlahDiminta)} berhasil dibuat.');
        Navigator.pop(context, true);
      } catch (e) {
        ToastHelper.showErrorToast(
            context, 'Gagal membuat permintaan: ${e.toString()}');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarik Saldo',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
                fontSize: 16,
                color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSaldoTersediaCard(),
              const SizedBox(height: 24),
              Text('Rekening Tujuan Penarikan',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _isLoadingRekening
                  ? _buildRekeningLoadingShimmer()
                  : _rekeningAktif != null
                      ? _buildRekeningInfoCard(_rekeningAktif!)
                      : _buildTidakAdaRekeningCard(),
              if (_rekeningErrorMessage != null &&
                  !_isLoadingRekening &&
                  _rekeningAktif == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Gagal memuat rekening: $_rekeningErrorMessage',
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              Text('Jumlah Penarikan',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jumlahController,
                decoration: InputDecoration(
                  hintText:
                      'Min. ${formatRupiah(_minimumPenarikan, includeSymbol: false)}',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final jumlah =
                      double.tryParse(value.replaceAll('.', '')) ?? 0;
                  if (jumlah < _minimumPenarikan) {
                    return 'Minimum penarikan adalah ${formatRupiah(_minimumPenarikan)}';
                  }
                  if (jumlah > widget.saldoTersedia) {
                    return 'Saldo Anda tidak mencukupi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildRingkasanPenarikan(),
              const SizedBox(height: 32),
              _isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Ajukan Penarikan'),
                      onPressed: (_rekeningAktif != null && !_isLoadingRekening)
                          ? _submitPenarikan
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaldoTersediaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: primaryColorLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Saldo Anda Saat Ini:',
              style: TextStyle(fontSize: 16, color: primaryColorDark)),
          Text(
            formatRupiah(widget.saldoTersedia),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColorText),
          ),
        ],
      ),
    );
  }

  Widget _buildRekeningLoadingShimmer() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
        ));
  }

  Widget _buildRekeningInfoCard(Map<String, dynamic> rekening) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.15),
          child: const Icon(Icons.account_balance_rounded, color: primaryColor),
        ),
        title: Text(rekening['namaBank']?.toString() ?? 'Nama Bank Tidak Ada',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${rekening['nomorRekening']?.toString() ?? 'No. Rekening Tidak Ada'}\na.n ${rekening['namaPenerima']?.toString() ?? 'Nama Pemilik Tidak Ada'}',
        ),
      ),
    );
  }

  Widget _buildTidakAdaRekeningCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange.shade700, size: 30),
            const SizedBox(height: 8),
            const Text(
              'Anda belum memiliki rekening bank ',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/informasi_rekening');
              },
              child: const Text('Tambahkan Rekening Sekarang',
                  style: TextStyle(
                      color: primaryColorDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanPenarikan() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Biaya Admin:', style: TextStyle(fontSize: 14)),
                Text(formatRupiah(_biayaAdmin),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jumlah Diterima:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  formatRupiah(_jumlahDiterima),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColorDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanText = newValue.text.replaceAll('.', '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }

    try {
      double value = double.parse(cleanText);

      final formatter = NumberFormat("#,###", "id_ID");
      String newText = formatter.format(value);

      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } catch (e) {
      return oldValue;
    }
  }
}
