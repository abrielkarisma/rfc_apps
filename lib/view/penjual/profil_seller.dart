import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/rekening.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/rekening.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class profileSeller extends StatefulWidget {
  const profileSeller({super.key});

  @override
  State<profileSeller> createState() => _profileSellerState();
}

String $name = "";
String $idUser = "";
String $phone = "";
String $address = "";
String $description = "";
String $avatarUrl = "";
String $bank = "";
String $noRek = "";
String $rekeningName = "";
bool rekeningRegistered = false;
int buttonSaveImage = 0;

final _namaRekeningController = TextEditingController();
final _jenisRekeningController = TextEditingController();
final _noRekeningController = TextEditingController();

class _profileSellerState extends State<profileSeller> {
  void initState() {
    super.initState();
    _getTokoDatabyId();
    rekeningRegistered = false;
    _getRekeningDataById();
  }

  void _getTokoDatabyId() async {
    try {
      final toko = await tokoService().getTokoByUserId();
      final String name = toko.data!.nama ?? "";
      final String tokoAvatar = toko.data!.logoToko ?? "";
      final String phone = toko.data!.phone ?? "";
      final String address = toko.data!.alamat ?? "";
      final String description = toko.data!.deskripsi ?? "";
      final String idUser = toko.data!.userId ?? "";

      setState(() {
        $name = name;
        $phone = phone;
        $address = address;
        $description = description;
        $avatarUrl = tokoAvatar;
        $idUser = idUser;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {});
    }
  }

  void _getRekeningDataById() async {
    try {
      final rekening = await rekeningService().getRekeningByUserId();
      final String rekeningName = rekening.data!.namaPenerima ?? "";
      final String bank = rekening.data!.namaBank ?? "";
      final String noRek = rekening.data!.nomorRekening ?? "";
      if (rekening.data == null) {
        rekeningRegistered = false;
      } else {
        rekeningRegistered = true;
        setState(() {
          $rekeningName = rekeningName;
          $bank = bank;
          $noRek = noRek;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {});
    }
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        $avatarUrl = image.path;
        buttonSaveImage = 1;
      });
    }
  }

  void _showEditTokoModal(BuildContext context) {
    final _namaTokoController = TextEditingController(text: $name);
    final _noHandphoneController = TextEditingController(text: $phone);
    final _alamatTokoController = TextEditingController(text: $address);
    final _deskripsiTokoController = TextEditingController(text: $description);
    Future<void> updateToko() async {
      print(_namaTokoController.text);
      try {
        final response = await tokoService().UpdateToko(
          $idUser,
          _namaTokoController.text,
          _noHandphoneController.text,
          _alamatTokoController.text,
          $avatarUrl,
          _deskripsiTokoController.text,
        );
        if (response.data == null) {
          ToastHelper.showErrorToast(context, 'Gagal memperbarui data toko!');
        } else {
          ToastHelper.showSuccessToast(
              context, 'Data toko berhasil diperbarui!');
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error: $e');
        ToastHelper.showErrorToast(context, 'Gagal memperbarui data toko!');
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Informasi Toko',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _namaTokoController,
                decoration: InputDecoration(
                  labelText: "Nama Toko",
                  hintText: "Masukkan nama toko",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noHandphoneController,
                decoration: InputDecoration(
                  labelText: "No Handphone",
                  hintText: "Masukkan nomor handphone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _alamatTokoController,
                decoration: InputDecoration(
                  labelText: "Alamat Toko",
                  hintText: "Masukkan alamat toko",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deskripsiTokoController,
                decoration: InputDecoration(
                  labelText: "Deskripsi Toko",
                  hintText: "Masukkan deskripsi toko",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    updateToko();
                    Navigator.pop(context, "refresh");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditRekeningModal(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: $rekeningName);
    final TextEditingController bankController =
        TextEditingController(text: $bank);
    final TextEditingController noRekController =
        TextEditingController(text: $noRek);
    Future<void> updateRekening() async {
      print(nameController.text);
      try {
        final response = await rekeningService().updateRekening(
          $idUser,
          nameController.text,
          bankController.text,
          noRekController.text,
        );
        if (response.data == null) {
          ToastHelper.showErrorToast(
              context, 'Gagal memperbarui data rekening!');
        } else {
          ToastHelper.showSuccessToast(
              context, 'Data rekening berhasil diperbarui!');
          Navigator.pop(context, "refresh");
        }
      } catch (e) {
        print('Error: $e');
        ToastHelper.showErrorToast(context, 'Gagal memperbarui data rekening!');
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Informasi Rekening',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: nameController,
                label: 'Nama Penerima',
                hint: 'Masukkan nama penerima',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: bankController,
                label: 'Nama Bank',
                hint: 'Contoh: BCA, BRI, Mandiri',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: noRekController,
                label: 'Nomor Rekening',
                hint: 'Masukkan nomor rekening',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    updateRekening();
                    Navigator.pop(context, "refresh");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddRekeningModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Rekening Baru',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _namaRekeningController,
                decoration: InputDecoration(
                  labelText: "Nama Penerima",
                  hintText: "Masukkan nama penerima rekening",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jenisRekeningController,
                decoration: InputDecoration(
                  labelText: "Nama Rekening",
                  hintText: "Masukkan jenis rekening (ex: BCA, BRI)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noRekeningController,
                decoration: InputDecoration(
                  labelText: "Nomor Rekening",
                  hintText: "Masukkan nomor rekening",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addRekening();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addRekening() async {
    String rekeningName = _namaRekeningController.text;
    String jenisRekening = _jenisRekeningController.text;
    String noRekening = _noRekeningController.text;

    if (rekeningName.isEmpty || jenisRekening.isEmpty || noRekening.isEmpty) {
      ToastHelper.showErrorToast(context, 'Lengkapi semua data rekening!');
      return;
    }

    print(rekeningName);
    print(jenisRekening);
    print(noRekening);
    try {
      final response = await rekeningService().CreateRekening(
        rekeningName,
        jenisRekening,
        noRekening,
      );  
      print(response);
      if (response.data == null) {
        ToastHelper.showErrorToast(context,
            'Gagal menambahkan rekening, coba lagi dalam beberapa saat');
      }
      if (response.data != null) {
        ToastHelper.showSuccessToast(context, 'Rekening berhasil ditambahkan!');
        Navigator.pop(context);
        _getRekeningDataById();
      }
    } catch (e) {
      print('Error: $e');
      ToastHelper.showErrorToast(context, 'Gagal menambahkan rekening');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Rooftop Farming Center.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "Monserrat_Alternates",
                  fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
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
            Container(
              child: Container(
                margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: context.getHeight(100),
                    bottom: 20),
                child: Column(children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Text(
                        "Profil Toko",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.getHeight(1)),
                  Column(
                    children: [
                      Container(
                        width: context.getWidth(100),
                        height: context.getHeight(100),
                        child: ClipOval(
                          child: buttonSaveImage == 1
                              ? Image(
                                  image: FileImage(
                                      File($avatarUrl)), // Use FileImage here
                                  fit: BoxFit.cover,
                                )
                              : ShimmerImage(
                                  imageUrl: $avatarUrl,
                                  width: context.getWidth(100),
                                  height: context.getHeight(100),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: context.getHeight(11)),
                      Container(
                          child: buttonSaveImage == 1
                              ? ElevatedButton(
                                  onPressed: () {
                                    _updateGambar();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    "Simpan Foto",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    _pickImage();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    "Ubah Foto",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                      const SizedBox(height: 24),
                      Container(
                        height: context.getHeight(575),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoCard(
                                title: "Informasi Toko",
                                icon: Icons.edit,
                                onEditTap: () {
                                  _showEditTokoModal(context);
                                },
                                content: [
                                  _InfoRow(
                                      label: "Nama",
                                      divider: ": ",
                                      value: $name),
                                  _InfoRow(
                                      label: "No Handphone",
                                      divider: ": ",
                                      value: $phone),
                                  _InfoRow(
                                    label: "Alamat Toko",
                                    divider: ": ",
                                    value: $address,
                                  ),
                                  _InfoRow(
                                    label: "Deskripsi Toko",
                                    divider: ": ",
                                    value: $description,
                                  ),
                                ],
                              ),
                              SizedBox(height: context.getHeight(45)),
                              rekeningRegistered
                                  ? _buildInfoCard(
                                      title: "Informasi Rekening",
                                      icon: Icons.edit,
                                      onEditTap: () {
                                        _showEditRekeningModal(context);
                                      },
                                      content: [
                                        _InfoRow(
                                            label: "Nama Penerima",
                                            divider: ": ",
                                            value: $rekeningName),
                                        _InfoRow(
                                            label: "Nama Rekening",
                                            divider: ": ",
                                            value: $bank),
                                        _InfoRow(
                                            label: "Nomor Rekening",
                                            divider: ": ",
                                            value: $noRek),
                                      ],
                                    )
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[200]!,
                                            blurRadius: 4,
                                            offset: const Offset(4, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.grey[200]!, width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Belum ada informasi rekening",
                                            style: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _showAddRekeningModal(context);
                                            },
                                            icon: const Icon(Icons.add,
                                                color: Colors.white),
                                            label: const Text(
                                              "Tambah Rekening",
                                              style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              SizedBox(height: context.getHeight(45)),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _modalLogout(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "LOGOUT",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          child: Icon(Icons.logout,
                                              color: Colors.red),
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
                  )
                ]),
              ),
            ),
          ],
        ));
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required VoidCallback onEditTap,
    required List<Widget> content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEditTap,
                child: Icon(icon, size: 18, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Future<void> _updateGambar() async {
    try {
      String uploadedPhotoUrl;
      if (buttonSaveImage == 1) {
        final cloudinaryService = CloudinaryService();
        final file = File($avatarUrl);
        if (file.existsSync()) {
          final uploadResult = await cloudinaryService.getUploadUrl(file);
          uploadedPhotoUrl = uploadResult['url'];
        } else {
          throw Exception('File gambar tidak ditemukan.');
        }
      } else {
        uploadedPhotoUrl = $avatarUrl;
      }
      final response =
          await tokoService().UpdateTokoGambar($idUser, uploadedPhotoUrl);
      print(response);
      if (response.data == null) {
        ToastHelper.showErrorToast(context, 'Gagal memperbarui gambar!');
      } else {
        ToastHelper.showSuccessToast(context, 'Gambar berhasil diperbarui!');
        setState(() {
          buttonSaveImage = 0;
        });
        Navigator.pop(context, "refresh");
      }
    } catch (e) {
      print('Error: $e');
      ToastHelper.showErrorToast(context, 'Gagal memperbarui gambar!');
    }
  }
}

void _modalLogout(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Apakah kamu yakin akan keluar dari akun?',
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 26,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEAEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final tokenStorage = FlutterSecureStorage();
                  tokenStorage.delete(key: 'token');
                  tokenStorage.delete(key: 'refreshToken');
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth',
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Ya, Logout',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Color(0xFF979797),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String divider;

  const _InfoRow(
      {required this.label, required this.value, required this.divider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            child: Text(
              "$label",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            "$divider",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    ],
  );
}
