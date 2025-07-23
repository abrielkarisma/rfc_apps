import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/rekening.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Color _primaryColor = Color(0xFF4CAD73);
const Color _primaryColorLight = Color(0xFFB3FFD2);

class InformasiRekeningPage extends StatefulWidget {
  const InformasiRekeningPage({super.key});

  @override
  State<InformasiRekeningPage> createState() => _InformasiRekeningPageState();
}

class _InformasiRekeningPageState extends State<InformasiRekeningPage> {
  final rekeningService _rekeningService = rekeningService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _rekening;
  bool _isLoading = true;
  String? _errorMessage;
  String _userId = "";

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _noRekController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchRekening();
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

  Future<void> _fetchRekening() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _getUserId();

    try {
      final rekening = _userId.isNotEmpty
          ? await _rekeningService.getRekeningByIdUser(_userId)
          : await _rekeningService.getRekeningBytoken();

      setState(() {
        _rekening = rekening;
        if (rekening != null) {
          _namaController.text = rekening['namaPenerima'] ?? '';
          _bankController.text = rekening['namaBank'] ?? '';
          _noRekController.text = rekening['nomorRekening']?.toString() ?? '';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      if (_rekening == null) {
        final res = await _rekeningService.CreateRekening(
          _namaController.text,
          _bankController.text,
          _noRekController.text,
        );
        if (res['message'] == 'Successfully created new rekening data') {
          ToastHelper.showSuccessToast(
              context, 'Rekening berhasil ditambahkan');
        }
      } else {
        final res = await _rekeningService.updateRekening(
          _rekening!['id'].toString(),
          _namaController.text,
          _bankController.text,
          _noRekController.text,
        );
        if (res['message'] == 'Successfully updated rekening data') {
          ToastHelper.showSuccessToast(context, 'Rekening berhasil diperbarui');
        }
      }
      await _fetchRekening();
      setState(() => _isEditMode = false);
    } catch (e) {
      ToastHelper.showErrorToast(context, e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Rekening',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
                fontSize: 16,
                color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchRekening,
                  color: _primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: _isEditMode || _rekening == null
                        ? Column(
                            children: [
                              Center(
                                  child: _rekening == null
                                      ? Text(
                                          "Anda belum menambahkan rekening, silahkan tambahkan rekening anda dibawah ini",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        )
                                      : Container()),
                              SizedBox(height: context.getHeight(16)),
                              _buildForm(),
                            ],
                          )
                        : _buildInfoCard(),
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _primaryColorLight,
              child: const Icon(Icons.account_balance_rounded,
                  color: _primaryColor),
            ),
            title: Text(
              _rekening?['namaBank']?.toString() ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                '${_rekening?['nomorRekening']?.toString() ?? '-'}\n${_rekening?['namaPenerima']?.toString() ?? '-'}'),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Edit Rekening'),
          onPressed: () => setState(() => _isEditMode = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _namaController,
            decoration: InputDecoration(
              labelText: 'Nama Penerima',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bankController,
            decoration: InputDecoration(
              labelText: 'Nama Bank',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noRekController,
            decoration: InputDecoration(
              labelText: 'Nomor Rekening',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty ? 'Tidak boleh kosong' : null,
          ),
          const SizedBox(height: 24),
          _isSubmitting
              ? const Center(
                  child: CircularProgressIndicator(color: _primaryColor))
              : ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Tambahkan Rekening'),
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
          if (_rekening != null)
            TextButton(
              onPressed: () => setState(() => _isEditMode = false),
              child: const Text('Batal'),
            ),
        ],
      ),
    );
  }
}
