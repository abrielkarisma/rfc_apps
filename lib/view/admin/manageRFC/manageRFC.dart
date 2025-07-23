import 'package:flutter/material.dart';
import 'package:rfc_apps/service/rfc_management.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'dart:io';

const Color appPrimaryColor = Color(0xFF6BC0CA);

class ManageRFCPageContent extends StatefulWidget {
  const ManageRFCPageContent({super.key});

  @override
  State<ManageRFCPageContent> createState() => _ManageRFCPageContentState();
}

class _ManageRFCPageContentState extends State<ManageRFCPageContent> {
  final RfcManagementService _rfcService = RfcManagementService();
  Map<String, dynamic>? _tokoRFC;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTokoRFC();
  }

  Future<void> _loadTokoRFC() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _rfcService.getTokoByTypeRFC();

      
      if (result['message'] != null &&
          result['data'] != null &&
          result['data'].isNotEmpty) {
        setState(() {
          _tokoRFC = result['data'][0];
          _isLoading = false;
        });
      } else if (result['message'] != null &&
          result['data'] != null &&
          result['data'].isEmpty) {
        setState(() {
          _tokoRFC = null;
          _isLoading = false;
        });
      } else if (result['status'] == false) {
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Gagal memuat data';
          _isLoading = false;
        });
      } else {
        setState(() {
          _tokoRFC = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: _tokoRFC != null
          ? FloatingActionButton(
              onPressed: _showEditTokoDialog,
              backgroundColor: appPrimaryColor,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: _showCreateTokoDialog,
              backgroundColor: appPrimaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: RefreshIndicator(
        onRefresh: _loadTokoRFC,
        color: appPrimaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appPrimaryColor),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTokoRFC,
              style: ElevatedButton.styleFrom(
                backgroundColor: appPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_tokoRFC == null) {
      return _buildCreateTokoView();
    }

    return _buildTokoView();
  }

  Widget _buildCreateTokoView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Toko RFC',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan buat toko RFC untuk memulai manajemen toko',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreateTokoDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Buat Toko RFC',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokoView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          
          Container(
            width: double.infinity,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appPrimaryColor.withOpacity(0.1),
                        Colors.green[50]!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: appPrimaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store,
                          color: appPrimaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Toko RFC',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: "Poppins",
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Kelola informasi toko RFC Anda',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Poppins",
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showEditTokoDialog(),
                        icon: const Icon(Icons.edit),
                        color: appPrimaryColor,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        icon: Icons.business,
                        label: 'Nama Toko',
                        value: _tokoRFC!['nama'] ?? '-',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: 'No. Telepon',
                        value: _tokoRFC!['phone'] ?? '-',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Alamat',
                        value: _tokoRFC!['alamat'] ?? '-',
                        isLongText: true,
                      ),
                      if (_tokoRFC!['deskripsi'] != null &&
                          _tokoRFC!['deskripsi'].isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.description,
                          label: 'Deskripsi',
                          value: _tokoRFC!['deskripsi'],
                          isLongText: true,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: 'Dibuat',
                        value: _formatDate(_tokoRFC!['createdAt']),
                      ),
                      if (_tokoRFC!['updatedAt'] != _tokoRFC!['createdAt']) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.update,
                          label: 'Diperbarui',
                          value: _formatDate(_tokoRFC!['updatedAt']),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLongText = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: "Poppins",
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: isLongText ? null : 1,
                overflow: isLongText ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showCreateTokoDialog() {
    showDialog(
      context: context,
      builder: (context) => TokoFormDialog(
        title: 'Buat Toko RFC',
        onSubmit: (data) async {
          final result = await _rfcService.createTokoWithTypeRFC(
            nama: data['nama']!,
            phone: data['phone']!,
            alamat: data['alamat']!,
            logoToko: data['logoToko'],
            deskripsi: data['deskripsi'],
          );

          if (result['message'] != null &&
              !result['message'].toString().toLowerCase().contains('error')) {
            Navigator.pop(context);
            ToastHelper.showSuccessToast(context, 'Toko RFC berhasil dibuat');
            _loadTokoRFC();
          } else {
            ToastHelper.showErrorToast(
                context, result['message'] ?? 'Gagal membuat toko');
          }
        },
      ),
    );
  }

  void _showEditTokoDialog() {
    if (_tokoRFC == null) return;

    showDialog(
      context: context,
      builder: (context) => TokoFormDialog(
        title: 'Edit Toko RFC',
        initialData: {
          'nama': _tokoRFC!['nama'] ?? '',
          'phone': _tokoRFC!['phone'] ?? '',
          'alamat': _tokoRFC!['alamat'] ?? '',
          'logoToko': _tokoRFC!['logoToko'] ?? '',
          'deskripsi': _tokoRFC!['deskripsi'] ?? '',
        },
        onSubmit: (data) async {
          final result = await _rfcService.updateTokoRFC(
            tokoId: _tokoRFC!['id'],
            nama: data['nama']!,
            phone: data['phone']!,
            alamat: data['alamat']!,
            logoToko: data['logoToko'],
            deskripsi: data['deskripsi'],
          );

          if (result['message'] != null &&
              !result['message'].toString().toLowerCase().contains('error')) {
            Navigator.pop(context);
            ToastHelper.showSuccessToast(
                context, 'Toko RFC berhasil diperbarui');
            _loadTokoRFC();
          } else {
            ToastHelper.showErrorToast(
                context, result['message'] ?? 'Gagal memperbarui toko');
          }
        },
      ),
    );
  }
}

class TokoFormDialog extends StatefulWidget {
  final String title;
  final Map<String, String>? initialData;
  final Function(Map<String, String>) onSubmit;

  const TokoFormDialog({
    super.key,
    required this.title,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<TokoFormDialog> createState() => _TokoFormDialogState();
}

class _TokoFormDialogState extends State<TokoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _logoTokoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _alamatController.text = widget.initialData!['alamat'] ?? '';
      _deskripsiController.text = widget.initialData!['deskripsi'] ?? '';
      _logoTokoPath = widget.initialData!['logoToko'];
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    ImagePickerHelper.showImageSourceOptions(
      context,
      onImageSelected: (File image) async {
        setState(() => _isLoading = true);

        try {
          final cloudinaryService = CloudinaryService();
          final result = await cloudinaryService.getUploadUrl(image);
          setState(() {
            _logoTokoPath = result['url'];
            _isLoading = false;
          });
          ToastHelper.showSuccessToast(context, 'Logo berhasil diupload');
        } catch (e) {
          setState(() => _isLoading = false);
          ToastHelper.showErrorToast(context, 'Gagal upload logo: $e');
        }
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'nama': _namaController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'logoToko': _logoTokoPath ?? '',
        'deskripsi': _deskripsiController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _logoTokoPath != null &&
                                          _logoTokoPath!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            _logoTokoPath!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.store,
                                                size: 50,
                                                color: Colors.grey[400],
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.store,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _pickLogo,
                              child: Text(
                                _logoTokoPath != null &&
                                        _logoTokoPath!.isNotEmpty
                                    ? 'Ganti Logo'
                                    : 'Pilih Logo',
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: appPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      
                      _buildTextField(
                        controller: _namaController,
                        label: 'Nama Toko *',
                        hint: 'Masukkan nama toko',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama toko harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      
                      _buildTextField(
                        controller: _phoneController,
                        label: 'No. Telepon *',
                        hint: 'Masukkan nomor telepon',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor telepon harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      
                      _buildTextField(
                        controller: _alamatController,
                        label: 'Alamat *',
                        hint: 'Masukkan alamat toko',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      
                      _buildTextField(
                        controller: _deskripsiController,
                        label: 'Deskripsi',
                        hint: 'Masukkan deskripsi toko (opsional)',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: "Poppins",
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appPrimaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
