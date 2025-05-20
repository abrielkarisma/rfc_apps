import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class Sellerstorereg extends StatefulWidget {
  const Sellerstorereg({Key? key}) : super(key: key);

  @override
  State<Sellerstorereg> createState() => _SellerstoreregState();
}

class _SellerstoreregState extends State<Sellerstorereg> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _logoFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  Future<void> _createToko() async {
    try {
      String? logoUrl;

      if (_logoFile != null) {
        final cloudinaryService = CloudinaryService();
        final uploadResult = await cloudinaryService.getUploadUrl(_logoFile!);
        logoUrl = uploadResult['url'];
      }

      final tokoServiceInstance = tokoService();
      final response = await tokoServiceInstance.createToko(
        _namaTokoController.text,
        _phoneController.text,
        _alamatController.text,
        logoUrl ?? '',
        _deskripsiController.text,
      );
      ToastHelper.showSuccessToast(context, "Berhasil membuat toko");
      Navigator.pop(context, 'refresh');
      print(response["message"]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat toko: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Toko", style: TextStyle(fontFamily: "Poppins")),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLabel("Nama Toko"),
              _buildTextField(
                controller: _namaTokoController,
                hintText: "Masukkan nama toko",
              ),
              SizedBox(height: context.getHeight(20)),
              _buildLabel("Alamat"),
              _buildTextField(
                controller: _alamatController,
                hintText: "Masukkan alamat toko",
                maxLines: 2,
              ),
              SizedBox(height: context.getHeight(20)),
              _buildLabel("Nomor Telepon"),
              _buildTextField(
                controller: _phoneController,
                hintText: "Masukkan nomor telepon",
              ),
              SizedBox(height: context.getHeight(20)),
              _buildLabel("Logo Toko"),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: context.getHeight(150),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _logoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _logoFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40, color: primaryColor),
                              SizedBox(height: 10),
                              Text("Pilih Gambar Logo",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: primaryColor,
                                    fontSize: 14,
                                  )),
                            ],
                          ),
                        ),
                ),
              ),
              SizedBox(height: context.getHeight(20)),
              _buildLabel("Deskripsi Toko"),
              _buildTextField(
                controller: _deskripsiController,
                hintText: "Masukkan deskripsi toko",
                maxLines: 4,
              ),
              SizedBox(height: context.getHeight(30)),
              SizedBox(
                width: double.infinity,
                height: context.getHeight(54),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _createToko();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Simpan",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontFamily: "Poppins"),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kolom ini tidak boleh kosong';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 14),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
