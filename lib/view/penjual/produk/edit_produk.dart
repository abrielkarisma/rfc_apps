import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class EditProduk extends StatefulWidget {
  final String id;
  final String nama;
  final String harga;
  final String stok;
  final String satuan;
  final String deskripsi;
  final String gambar;
  final bool isDeleted;
  final String typeToko;

  const EditProduk({
    super.key,
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.satuan,
    required this.deskripsi,
    required this.gambar,
    required this.isDeleted,
    required this.typeToko,
  });

  @override
  State<EditProduk> createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _deskripsiProdukController =
      TextEditingController();
  final TextEditingController _stokProdukController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  bool editStokSatuan = false;
  String? _produkPhoto;
  String _produkgambar = "";
  bool _imageChanged = false;

  String? _selectedSatuan;
  final List<String> _satuanList = ['buah', 'ekor', 'gr', 'kg', 'ikat', 'pcs'];

  bool _isLoading = false;

  @override
  void initState() {
    editStokSatuan = false;
    editStatus();
    super.initState();

    _namaProdukController.text = widget.nama;
    _deskripsiProdukController.text = widget.deskripsi;
    _stokProdukController.text = widget.stok;
    _hargaProdukController.text = widget.harga;
    _selectedSatuan = widget.satuan;
    _produkgambar = widget.gambar;
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _deskripsiProdukController.dispose();
    _stokProdukController.dispose();
    _hargaProdukController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    ImagePickerHelper.showImageSourceOptions(
      context,
      onImageSelected: (File selectedImage) {
        setState(() {
          _produkPhoto = selectedImage.path;
          _imageChanged = true;
        });
      },
    );
  }

  Future<void> editStatus() async {
    if (widget.typeToko == "rfc") {
      setState(() {
        editStokSatuan = true;
        _selectedSatuan = widget.satuan;
      });
    } else if (widget == "umkm") {
      setState(() {
        editStokSatuan = false;
      });
    }
  }

  Future<void> _updateProduk() async {
    setState(() {
      _isLoading = true;
    });

    String namaProduk = _namaProdukController.text.trim();
    String deskripsiProduk = _deskripsiProdukController.text.trim();
    String stokProduk = _stokProdukController.text.trim();
    String hargaProduk = _hargaProdukController.text.trim();

    if (namaProduk.isEmpty ||
        deskripsiProduk.isEmpty ||
        stokProduk.isEmpty ||
        hargaProduk.isEmpty ||
        _selectedSatuan == null) {
      ToastHelper.showErrorToast(context, "Semua field harus diisi!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String imageUrl = _produkgambar;

      if (_imageChanged && _produkPhoto != null) {
        final cloudinaryService = CloudinaryService();
        final uploadResponse =
            await cloudinaryService.getUploadUrl(File(_produkPhoto!));
        imageUrl = uploadResponse['url'];
      }

      final produkService = ProdukService();
      final response = await produkService.updateProduk(
        widget.id,
        namaProduk,
        hargaProduk,
        stokProduk,
        _selectedSatuan!,
        deskripsiProduk,
        imageUrl,
      );

      if (response.message == "Successfully updated produk data") {
        ToastHelper.showSuccessToast(context, "Produk berhasil diperbarui!");
        Navigator.pop(context, "refresh");
      } else {
        ToastHelper.showErrorToast(context, response.message);
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, "Terjadi kesalahan: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _nonaktifkanProduk() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final produkService = ProdukService();
      final response = await produkService.deleteProduk(widget.id);

      if (response.message == "Successfully deleted produk data") {
        ToastHelper.showSuccessToast(context, "Produk berhasil dinonaktifkan!");
        Navigator.pop(context, "refresh");
      } else {
        ToastHelper.showErrorToast(context, response.message);
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, "Terjadi kesalahan: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _aktivasiProduk() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final produkService = ProdukService();
      final response = await produkService.activateProduk(widget.id);

      if (response.message == "Successfully activated produk data") {
        ToastHelper.showSuccessToast(context, "Produk berhasil diaktifkan!");
        Navigator.pop(context, "refresh");
      } else {
        ToastHelper.showErrorToast(context, response.message);
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, "Terjadi kesalahan: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Rooftop Farming Center.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/homebackground.png',
            fit: BoxFit.fill,
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit Produk",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.getHeight(47)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gambar Produk",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: "Poppins")),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.green,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                            child: _imageChanged && _produkPhoto != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_produkPhoto!),
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: 150,
                                    ),
                                  )
                                : _produkgambar.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          _produkgambar,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: 150,
                                        ),
                                      )
                                    : const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.file_upload_outlined,
                                                color: Colors.green),
                                            SizedBox(height: 5),
                                            Text("Upload",
                                                style: TextStyle(
                                                    color: Colors.green)),
                                          ],
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Nama Produk",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: "Poppins")),
                        const SizedBox(height: 5),
                        _buildTextField(controller: _namaProdukController),
                        const SizedBox(height: 15),
                        Text("Deskripsi Produk",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: "Poppins")),
                        const SizedBox(height: 5),
                        _buildTextField(
                            controller: _deskripsiProdukController,
                            maxLines: 3),
                        const SizedBox(height: 15),
                        Text("Stok Produk & Satuan",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: "Poppins")),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _stokProdukController,
                                keyboardType: TextInputType.number,
                                enabled: !editStokSatuan,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedSatuan,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: editStokSatuan
                                      ? Colors.grey[300]
                                      : Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                hint: Text("Satuan",
                                    style: TextStyle(
                                        fontFamily: "Poppins", fontSize: 14)),
                                items: _satuanList.map((String satuan) {
                                  return DropdownMenuItem<String>(
                                    value: satuan,
                                    child: Text(satuan,
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: editStokSatuan
                                    ? null
                                    : (String? value) {
                                        setState(() {
                                          _selectedSatuan = value;
                                        });
                                      },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text("Harga Produk",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: "Poppins")),
                        const SizedBox(height: 5),
                        _buildTextField(
                            controller: _hargaProdukController,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _updateProduk,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("Perbarui",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Poppins")),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isDeleted
                                  ? Color(0xFF4CAD73)
                                  : Color(0xFFFF8C00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : (widget.isDeleted
                                    ? _aktivasiProduk
                                    : _nonaktifkanProduk),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    widget.isDeleted
                                        ? "Aktifkan Produk"
                                        : "Nonaktifkan Produk",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Poppins")),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ))
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.grey[200] : Colors.grey[300],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
          color: enabled ? Colors.black : Colors.grey[600], fontSize: 16),
    );
  }
}
