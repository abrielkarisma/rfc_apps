import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Shows a bottom sheet with options to pick an image from gallery or camera
  static Future<void> showImageSourceOptions(
    BuildContext context, {
    required Function(File) onImageSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: SvgPicture.asset('assets/images/photos.svg',
                      width: 24, height: 24),
                  title: Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImageFromSource(ImageSource.gallery,
                        onImageSelected: onImageSelected);
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset('assets/images/camera.svg',
                      width: 24, height: 24),
                  title: Text('Ambil Foto',
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      )),
                  onTap: () {
                    Navigator.pop(context);
                    pickImageFromSource(ImageSource.camera,
                        onImageSelected: onImageSelected);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Picks an image from the specified source and handles cropping
  static Future<void> pickImageFromSource(
    ImageSource source, {
    required Function(File) onImageSelected,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        File? croppedImage = await cropImage(File(image.path));
        if (croppedImage != null) {
          onImageSelected(croppedImage);
        }
      }
    } catch (e) {
      print('Error picking or cropping image: $e');
    }
  }

  /// Directly pick from gallery without showing the options bottom sheet
  static Future<void> pickFromGallery({
    required Function(File) onImageSelected,
  }) async {
    await pickImageFromSource(ImageSource.gallery,
        onImageSelected: onImageSelected);
  }

  /// Directly pick from camera without showing the options bottom sheet
  static Future<void> pickFromCamera({
    required Function(File) onImageSelected,
  }) async {
    await pickImageFromSource(ImageSource.camera,
        onImageSelected: onImageSelected);
  }

  /// Crops the image with a square (1:1) aspect ratio
  static Future<File?> cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio:
          const CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 aspect ratio
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Sesuaikan Foto',
          toolbarColor: Colors.green,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  static uploadImage(String profilePhoto, order) {}
}
