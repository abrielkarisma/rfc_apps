import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/rekening.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class profileSeller extends StatefulWidget {
  final String idUser; 

  const profileSeller({super.key, required this.idUser});

  
  static Widget fromRoute(BuildContext context, String idUser) {
    return profileSeller(idUser: idUser);
  }

  @override
  State<profileSeller> createState() => _profileSellerState();
}

class _profileSellerState extends State<profileSeller> {
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
  @override
  void initState() {
    super.initState();
    $idUser = widget.idUser;
    _getTokoDatabyId();
    rekeningRegistered = false;
    _getRekeningDataById();
  }

  void _getTokoDatabyId() async {
    try {
      final toko = await tokoService().getTokoByIdUser($idUser);

      if (toko.data.isNotEmpty) {
        final String name = toko.data[0].nama;
        final String tokoAvatar = toko.data[0].logoToko;
        final String phone = toko.data[0].phone;
        final String address = toko.data[0].alamat;
        final String description = toko.data[0].deskripsi;

        setState(() {
          $name = name;
          $phone = phone;
          $address = address;
          $description = description;
          $avatarUrl = tokoAvatar;
        });
      }
    } catch (e) {
      print("Error getting toko data: $e");
      setState(() {});
    }
  }

  void _getRekeningDataById() async {
    try {
      final rekening = await rekeningService().getRekeningByUserId($idUser);
      if (rekening.data == null) {
        setState(() {
          rekeningRegistered = false;
        });
      } else {
        final String rekeningName = rekening.data!.namaPenerima ?? "";
        final String bank = rekening.data!.namaBank ?? "";
        final String noRek = rekening.data!.nomorRekening ?? "";

        setState(() {
          rekeningRegistered = true;
          $rekeningName = rekeningName;
          $bank = bank;
          $noRek = noRek;
        });
      }
    } catch (e) {
      print("Error getting rekening data: $e");
      setState(() {
        rekeningRegistered = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    _getTokoDatabyId();
    _getRekeningDataById();
  }

  void _pickImage() async {
    ImagePickerHelper.showImageSourceOptions(
      context,
      onImageSelected: (File selectedImage) {
        setState(() {
          $avatarUrl = selectedImage.path;
          buttonSaveImage = 1;
        });
      },
    );
  }

  void _showEditTokoModal(BuildContext context) {
    final _namaTokoController = TextEditingController(text: $name);
    final _noHandphoneController = TextEditingController(text: $phone);
    final _alamatTokoController = TextEditingController(text: $address);
    final _deskripsiTokoController = TextEditingController(text: $description);
    Future<void> updateToko() async {
      try {
        final response = await tokoService().UpdateToko(
          $idUser,
          _namaTokoController.text,
          _noHandphoneController.text,
          _alamatTokoController.text,
          $avatarUrl,
          _deskripsiTokoController.text,
        );
        if (response['message'] == "Successfully updated toko") {
          ToastHelper.showSuccessToast(
              context, 'Data toko berhasil diperbarui!');
          Navigator.pop(context);
        } else {
          ToastHelper.showErrorToast(context, 'Gagal memperbarui data toko!');
        }
      } catch (e) {
        ToastHelper.showErrorToast(context, 'Gagal memperbarui data toko!');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Informasi Toko',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModalTextField(
                    controller: _namaTokoController,
                    label: "Nama Toko",
                    hint: "Masukkan nama toko",
                    icon: Icons.store_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: _noHandphoneController,
                    label: "No Handphone",
                    hint: "Masukkan nomor handphone",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: _alamatTokoController,
                    label: "Alamat Toko",
                    hint: "Masukkan alamat toko",
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: _deskripsiTokoController,
                    label: "Deskripsi Toko",
                    hint: "Masukkan deskripsi toko",
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
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
      try {
        final response = await rekeningService().updateRekening(
          $idUser,
          nameController.text,
          bankController.text,
          noRekController.text,
        );
        if (response["message"] == "Successfully updated rekening data") {
          ToastHelper.showSuccessToast(
              context, 'Data rekening berhasil diperbarui!');
          Navigator.pop(context, "refresh");
        } else {
          ToastHelper.showErrorToast(
              context, "Gagal memperbarui data rekening!");
        }
      } catch (e) {
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
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Informasi Rekening',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModalTextField(
                    controller: nameController,
                    label: 'Nama Penerima',
                    hint: 'Masukkan nama penerima',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: bankController,
                    label: 'Nama Bank',
                    hint: 'Contoh: BCA, BRI, Mandiri',
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: noRekController,
                    label: 'Nomor Rekening',
                    hint: 'Masukkan nomor rekening',
                    icon: Icons.credit_card_outlined,
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
            ),
          ),
        );
      },
    );
  }

  void _showAddRekeningModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_card_rounded,
                          color: Colors.green[600],
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tambah Rekening Baru',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModalTextField(
                    controller: _namaRekeningController,
                    label: "Nama Penerima",
                    hint: "Masukkan nama penerima rekening",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: _jenisRekeningController,
                    label: "Nama Bank",
                    hint: "Contoh: BCA, BRI, Mandiri",
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildModalTextField(
                    controller: _noRekeningController,
                    label: "Nomor Rekening",
                    hint: "Masukkan nomor rekening",
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _addRekening();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Rekening',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
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

    try {
      final response = await rekeningService().CreateRekening(
        rekeningName,
        jenisRekening,
        noRekening,
      );
      if (response["message"] == "Successfully created new rekening data") {
        ToastHelper.showSuccessToast(context, 'Rekening berhasil ditambahkan!');
        Navigator.pop(context, "refresh");
        _getRekeningDataById();
      } else {
        ToastHelper.showErrorToast(context,
            'Gagal menambahkan rekening, coba lagi dalam beberapa saat');
      }
    } catch (e) {
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/homebackground.png',
                  fit: BoxFit.fill,
                ),
              ),
              SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                      image: FileImage(File($avatarUrl)),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoCard(
                                    title: "Informasi Toko",
                                    icon: Icons.edit_rounded,
                                    onEditTap: () {
                                      _showEditTokoModal(context);
                                    },
                                    content: [
                                      _InfoRow(
                                          label: "Nama Toko",
                                          divider: ": ",
                                          value: $name.isNotEmpty
                                              ? $name
                                              : "Belum diatur"),
                                      _InfoRow(
                                          label: "No. Handphone",
                                          divider: ": ",
                                          value: $phone.isNotEmpty
                                              ? $phone
                                              : "Belum diatur"),
                                      _InfoRow(
                                        label: "Alamat Toko",
                                        divider: ": ",
                                        value: $address.isNotEmpty
                                            ? $address
                                            : "Belum diatur",
                                      ),
                                      _InfoRow(
                                        label: "Deskripsi",
                                        divider: ": ",
                                        value: $description.isNotEmpty
                                            ? $description
                                            : "Belum diatur",
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: context.getHeight(16)),
                                  rekeningRegistered
                                      ? _buildInfoCard(
                                          title: "Informasi Rekening",
                                          icon: Icons.edit_rounded,
                                          onEditTap: () {
                                            _showEditRekeningModal(context);
                                          },
                                          content: [
                                            _InfoRow(
                                                label: "Nama Penerima",
                                                divider: ": ",
                                                value: $rekeningName.isNotEmpty
                                                    ? $rekeningName
                                                    : "Belum diatur"),
                                            _InfoRow(
                                                label: "Bank",
                                                divider: ": ",
                                                value: $bank.isNotEmpty
                                                    ? $bank
                                                    : "Belum diatur"),
                                            _InfoRow(
                                                label: "No. Rekening",
                                                divider: ": ",
                                                value: $noRek.isNotEmpty
                                                    ? $noRek
                                                    : "Belum diatur"),
                                          ],
                                        )
                                      : _buildInfoCard(
                                          title: "Informasi Rekening",
                                          icon: Icons.add_circle_outline,
                                          onEditTap: () {
                                            _showAddRekeningModal(context);
                                          },
                                          content: [
                                            Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.blue[100]!,
                                                    width: 1),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .account_balance_wallet_outlined,
                                                    size: 40,
                                                    color: Colors.blue[400],
                                                  ),
                                                  SizedBox(height: 12),
                                                  Text(
                                                    "Belum ada rekening terdaftar",
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: Colors.blue[700],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Tap ikon edit untuk menambahkan rekening",
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  SizedBox(height: context.getHeight(24)),
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _modalLogout(context),
                                      icon: Icon(Icons.logout_rounded,
                                          color: Colors.white, size: 18),
                                      label: Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        elevation: 2,
                                        shadowColor:
                                            Colors.red.withOpacity(0.3),
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
                  ))
            ],
          ),
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
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey[100]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      title == "Informasi Toko"
                          ? Icons.store_rounded
                          : Icons.account_balance_rounded,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: onEditTap,
                      child: Icon(icon, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(fontFamily: "Poppins", fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines > 1 ? 16 : 12,
                horizontal: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
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
      if (response["message"] == "Successfully updated toko") {
        ToastHelper.showSuccessToast(context, 'Gambar berhasil diperbarui!');
        setState(() {
          buttonSaveImage = 0;
        });
        Navigator.pop(context, "refresh");
      } else {
        ToastHelper.showErrorToast(context, 'Gagal memperbarui gambar!');
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, 'Gagal memperbarui gambar!');
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String divider;

  const _InfoRow(
      {required this.label, required this.value, required this.divider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            divider,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Belum diatur",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: value.isNotEmpty ? Colors.black87 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
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
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Apakah kamu yakin akan keluar dari akun?',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                onPressed: () {
                  final tokenStorage = FlutterSecureStorage();
                  tokenStorage.deleteAll();
                  tokenStorage.delete(key: 'token');
                  tokenStorage.delete(key: 'refreshToken');
                  tokenStorage.delete(key: 'role');
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth',
                    (Route<dynamic> route) => false,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Ya, Logout',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
