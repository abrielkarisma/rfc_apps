import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _deskripsiProdukController =
      TextEditingController();
  final TextEditingController _stokProdukController = TextEditingController();
  final TextEditingController _hargaProdukController = TextEditingController();
  String? _produkgambar;
  String? _produkPhoto;

  String? _selectedSatuan;
  final List<String> _satuanList = ['buah', 'ekor', 'gr', 'kg', 'ikat', 'pcs'];

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
        });
      },
    );
  }

  Future<void> _createProduk() async {
    String namaProduk = _namaProdukController.text.trim();
    String deskripsiProduk = _deskripsiProdukController.text.trim();
    String stokProduk = _stokProdukController.text.trim();
    String hargaProduk = _hargaProdukController.text.trim();

    if (namaProduk.isEmpty ||
        deskripsiProduk.isEmpty ||
        stokProduk.isEmpty ||
        hargaProduk.isEmpty ||
        _selectedSatuan == null ||
        _produkPhoto == null) {
      ToastHelper.showErrorToast(context, "Semua field harus diisi!");
      return;
    }

    try {
      final cloudinaryService = CloudinaryService();
      final imageUrl =
          await cloudinaryService.getUploadUrl(File(_produkPhoto!));
      _produkgambar = imageUrl['url'];
      final produkService = ProdukService();
      final response = await produkService.createProduk(
        namaProduk,
        hargaProduk,
        stokProduk,
        _selectedSatuan!,
        deskripsiProduk,
        _produkgambar!,
      );
      if (response['message'] == "Berhasil menambahkan produk") {
        ToastHelper.showSuccessToast(context, "Produk berhasil disimpan!");
        Navigator.pop(context, "refresh");
      } else {
        ToastHelper.showErrorToast(
            context, response['message'] ?? "Gagal menyimpan produk");
      }
    } catch (e) {
      ToastHelper.showErrorToast(
          context, "Terjadi kesalahannnn: ${e.toString()}");
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'assets/images/homebackground.png',
                fit: BoxFit.cover,
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
                      "Tambah Produk",
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
                            child: _produkPhoto == null
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.file_upload_outlined,
                                            color: Colors.green),
                                        SizedBox(height: 5),
                                        Text("Upload",
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_produkPhoto!),
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: 150,
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
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedSatuan,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
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
                                onChanged: (String? value) {
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
                            onPressed: () {
                              _createProduk();
                            },
                            child: Text("Simpan",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins")),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.black, fontSize: 16),
    );
  }
}
