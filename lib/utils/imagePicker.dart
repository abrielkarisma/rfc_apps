import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  
  static Future<bool> _requestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      var cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }
      return cameraStatus.isGranted;
    } else {
      
      var storageStatus = await Permission.photos.status;
      if (storageStatus.isDenied) {
        storageStatus = await Permission.photos.request();
      }

      
      if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
        var mediaStatus = await Permission.storage.status;
        if (mediaStatus.isDenied) {
          mediaStatus = await Permission.storage.request();
        }
        return mediaStatus.isGranted;
      }

      return storageStatus.isGranted;
    }
  }

  
  static void _showPermissionDeniedDialog(
      BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Izin Diperlukan'),
          content: Text(
              'Aplikasi memerlukan izin $permission untuk melanjutkan. Silakan berikan izin di pengaturan aplikasi.'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Pengaturan'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  
  static Future<void> showImageSourceOptions(
    BuildContext context, {
    required Function(File) onImageSelected,
    bool shouldCrop = true,
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
                    pickImageFromSource(
                      ImageSource.gallery,
                      onImageSelected: onImageSelected,
                      shouldCrop: shouldCrop,
                      context: context,
                    );
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
                    pickImageFromSource(
                      ImageSource.camera,
                      onImageSelected: onImageSelected,
                      shouldCrop: shouldCrop,
                      context: context,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  
  static Future<void> pickImageFromSource(
    ImageSource source, {
    required Function(File) onImageSelected,
    bool shouldCrop = true,
    BuildContext? context,
  }) async {
    try {
      
      bool hasPermission = await _requestPermissions(source);

      if (!hasPermission) {
        if (context != null) {
          String permissionType =
              source == ImageSource.camera ? 'kamera' : 'galeri';
          _showPermissionDeniedDialog(context, permissionType);
        }
        return;
      }

      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        File file = File(image.path);
        if (shouldCrop) {
          File? croppedImage = await cropImageFile(file);
          if (croppedImage != null) {
            onImageSelected(croppedImage);
          }
        } else {
          onImageSelected(file);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  
  static Future<void> pickFromGallery({
    required Function(File) onImageSelected,
    bool shouldCrop = true,
    BuildContext? context,
  }) async {
    await pickImageFromSource(ImageSource.gallery,
        onImageSelected: onImageSelected,
        shouldCrop: shouldCrop,
        context: context);
  }

  
  static Future<void> pickFromCamera({
    required Function(File) onImageSelected,
    bool shouldCrop = true,
    BuildContext? context,
  }) async {
    await pickImageFromSource(ImageSource.camera,
        onImageSelected: onImageSelected,
        shouldCrop: shouldCrop,
        context: context);
  }

  
  static Future<File?> cropImageFile(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio:
          const CropAspectRatio(ratioX: 1, ratioY: 1), 
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
