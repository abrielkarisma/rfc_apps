import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/komoditas.dart';
import 'package:rfc_apps/service/komoditas.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class DetailKomoditasPage extends StatefulWidget {
  final String id;
  const DetailKomoditasPage({super.key, required this.id});

  @override
  State<DetailKomoditasPage> createState() => _DetailKomoditasPageState();
}

class _DetailKomoditasPageState extends State<DetailKomoditasPage> {
  KomoditasData? data;
  final _formKey = GlobalKey<FormState>();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final komoditas = await KomoditasService().getKomoditasById(widget.id);
      setState(() {
        data = komoditas;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ProdukService().createProductByKomoditas(
        widget.id,
        data!.nama,
        _hargaController.text,
        data!.jumlah.toString(),
        data!.satuan.lambang.toLowerCase(),
        _deskripsiController.text,
        data!.gambar,
      );

      if (mounted) {
        ToastHelper.showSuccessToast(
          context,
          'Produk berhasil ditambahkan',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showErrorToast(
          context,
          'Gagal menambahkan produk: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(' : ',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Detail Komoditas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Monserrat_Alternates',
              fontWeight: FontWeight.w600,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/homebackground.png',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
            child: data == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: context.getWidth(300),
                            height: context.getHeight(300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                  Colors.white.withOpacity(0.8),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ShimmerImage(
                                    imageUrl: data!.gambar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: context.getHeight(20)),
                          Container(
                            width: double.infinity,
                            child: Text("Informasi Komoditas",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                )),
                          ),
                          _buildRow('Nama Komoditas', data!.nama),
                          _buildRow('Jumlah', data!.jumlah.toString()),
                          _buildRow('Tipe', data!.tipeKomoditas),
                          _buildRow('Satuan', data!.satuan.nama),
                          _buildRow('Jenis Budidaya', data!.jenisBudidaya.nama),
                          SizedBox(height: context.getHeight(30)),
                          Container(
                            width: double.infinity,
                            child: Text("Tambah Produk",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                )),
                          ),
                          _buildFormField(
                            label: 'Harga per ${data!.satuan.nama}',
                            controller: _hargaController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harga tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Harga harus berupa angka';
                              }
                              if (int.parse(value) <= 0) {
                                return 'Harga harus lebih dari 0';
                              }
                              return null;
                            },
                          ),
                          _buildFormField(
                            label: 'Deskripsi Produk',
                            controller: _deskripsiController,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
                              }
                              if (value.length < 10) {
                                return 'Deskripsi minimal 10 karakter';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: context.getHeight(100)),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isLoading ? null : _createProduct,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tambahkan Produk",
                        style: TextStyle(
                            fontFamily: 'poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
