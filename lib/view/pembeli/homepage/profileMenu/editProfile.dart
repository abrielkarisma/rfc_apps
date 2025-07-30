import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/cloudinary.dart';
import 'package:rfc_apps/service/user.dart';
import 'package:rfc_apps/utils/imagePicker.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/pembeli/homepage/profileMenu/profil.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(
      {super.key,
      required this.name,
      required this.email,
      required this.phone,
      required this.userId,
      required this.avatarUrl});
  final String name;
  final String email;
  final String phone;
  final String userId;
  final String avatarUrl;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _profilePhoto;
  int ImageType = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _profilePhoto = widget.avatarUrl;
    ImageType = 0;
  }

  Future<void> _saveEditProfile() async {
    try {
      String uploadedPhotoUrl;

      if (ImageType == 1) {
        final cloudinaryService = CloudinaryService();
        final file = File(_profilePhoto);
        if (file.existsSync()) {
          final uploadResult = await cloudinaryService.getUploadUrl(file);
          uploadedPhotoUrl = uploadResult['url'];
        } else {
          throw Exception('File gambar tidak ditemukan.');
        }
      } else {
        uploadedPhotoUrl = _profilePhoto;
      }
      await UserService().UpdateUser(
        widget.userId,
        _nameController.text,
        uploadedPhotoUrl,
      );
      Navigator.pop(context, "refresh");
    } catch (e) {
      ToastHelper.showErrorToast(context, 'Gagal update profile: $e');
    }
  }

  Future<void> _pickImage() async {
    ImagePickerHelper.showImageSourceOptions(
      context,
      onImageSelected: (File image) {
        setState(() {
          _profilePhoto = image.path;
          ImageType = 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rooftop Farming Center.",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: "Monserrat_Alternates",
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
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
                    left: 20,
                    right: 20,
                    top: context.getHeight(100),
                    bottom: 20),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            "Edit Profil",
                            style: const TextStyle(
                              fontFamily: "poppins",
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              width: context.getWidth(100),
                              height: context.getHeight(100),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[200]!,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: ImageType == 0
                                    ? _profilePhoto.endsWith('.svg')
                                        ? SvgPicture.network(
                                            _profilePhoto,
                                            fit: BoxFit.cover,
                                            placeholderBuilder:
                                                (BuildContext context) =>
                                                    Container(
                                              padding: const EdgeInsets.all(20),
                                              child:
                                                  const CircularProgressIndicator(),
                                            ),
                                          )
                                        : Image.network(
                                            _profilePhoto,
                                            fit: BoxFit.cover,
                                          )
                                    : Image(
                                        image: FileImage(File(_profilePhoto)),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(height: context.getHeight(14)),
                            ElevatedButton(
                              onPressed: () {
                                _pickImage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Ganti Foto Profil',
                                style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: context.getHeight(27)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nama',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "poppins",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "poppins",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'No. Handphone',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "poppins",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _phoneController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.getHeight(163)),
                                Container(
                                  width: double.infinity,
                                  height: context.getHeight(45),
                                  margin: EdgeInsets.only(
                                      top: context.getHeight(7)),
                                  child: TextButton(
                                    onPressed: () {
                                      _saveEditProfile();
                                    },
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: "poppins",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
