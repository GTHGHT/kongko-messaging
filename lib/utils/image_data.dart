import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageData extends ChangeNotifier {
  File? _image;

  set image(File? value) {
    _image = value;
    notifyListeners();
  }

  File? get image => _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> showImagePickerDialog(BuildContext context) async {
    showSnackBar(String content) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(content),
          ),
        );
    }
    await showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Pilih Sumber"),
        children: [
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text("dari Galeri"),
            onTap: () async {
              await getImage(ImageSource.gallery,showSnackBar);
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("dari Kamera"),
            onTap: () async {
              await getImage(ImageSource.camera,showSnackBar);
              Navigator.pop(ctx);
            },
          )
        ],
      ),
    );
  }

  Future<bool> requestCameraPermissions() async {
    PermissionStatus permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted) {
      final permissions = await Permission.camera.request();
      return permissions == PermissionStatus.granted;
    } else {
      return true;
    }
  }

  Future<bool> requestStoragePermissions() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      final permissions = await Permission.storage.request();
      return permissions == PermissionStatus.granted;
    } else {
      return true;
    }
  }

  Future<void> getImage(
      ImageSource source, void Function(String message) showSnackBar) async {
    if (source == ImageSource.camera
        ? await requestCameraPermissions()
        : await requestStoragePermissions()) {
      final pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          aspectRatioPresets: [CropAspectRatioPreset.square],
          compressQuality: 90,
          compressFormat: ImageCompressFormat.jpg,
        );
        if (croppedImage != null) {
          final fileImage = File(croppedImage.path);
          _image = fileImage;
          notifyListeners();
        } else {
          showSnackBar("Crop Image Terlebih Dahulu");
        }
      } else {
        showSnackBar("Tidak Ada Gambar Yang Dipilih");
      }
    }
  }

  void clearImage(){
    _image = null;
    notifyListeners();
  }
}